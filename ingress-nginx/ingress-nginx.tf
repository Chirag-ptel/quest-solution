provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest/ingress-nginx/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}
# data "aws_eks_cluster_auth" "cluster" {
#   name = var.cluster_name
# }
# data "aws_iam_openid_connect_provider" "oidc_provider" {
#   url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   }
# }

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

resource "helm_release" "ingress_nginx_controller" {
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace
  create_namespace = true
  # upgrade_install = true

  values = [file("${path.module}/ingress-helm-values.yaml")]
}