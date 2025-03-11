provider "aws" {
  region  = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest/secret-csi-driver/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint #module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) #base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "secret-csi-driver" {
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
#   version    = var.helm_chart_version
  namespace  = var.namespace
  create_namespace = true

  set {
    name  = "syncSecret.enabled"
    value = true
  }

}

resource "helm_release" "secrets_store_csi_driver_provider" {
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name_secret_provider
  chart      = var.helm_chart_release_name_secret_provider
  repository = var.helm_chart_repo_secret_provider
#   version    = var.helm_chart_version
  namespace  = var.namespace

}

resource "aws_iam_role" "quest_deployment_role" {
  name               = "quest-deployment-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action   = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "quest_deployment_policy" {
  name        = "quest-deployment-policy"
  description = "Policy for quest deployment to access secrets in Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "${aws_secretsmanager_secret.quest_secret.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "quest_deployment_role_policy_attachment" {
  role       = aws_iam_role.quest_deployment_role.name
  policy_arn = aws_iam_policy.quest_deployment_policy.arn
}


resource "aws_secretsmanager_secret" "quest_secret" {
  name = "quest-secret" 
}

resource "aws_secretsmanager_secret_version" "quest_secret_version" {
  secret_id     = aws_secretsmanager_secret.quest_secret.id
  secret_string = jsonencode(var.quest_secret)
}

resource "aws_eks_pod_identity_association" "quest_pod_identity_association" {
  cluster_name           = var.cluster_name
  service_account        = "quest-deployment-sa"
  namespace              = "default"
  role_arn               = aws_iam_role.quest_deployment_role.arn
}



