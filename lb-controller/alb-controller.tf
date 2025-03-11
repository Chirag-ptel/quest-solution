provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest/lb-controller/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name 
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name 
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}




# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name ]
#     command     = "aws"
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

resource "helm_release" "alb_controller" {
  depends_on = [var.mod_dependency]  #, kubernetes_namespace.alb_controller]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kubernetes_alb_controller[0].arn
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  values = [
    yamlencode(var.settings)
  ]

}

#### iam ####

resource "aws_iam_policy" "kubernetes_alb_controller" {
  depends_on  = [var.mod_dependency]
  count       = var.enabled ? 1 : 0
  name        = "${var.cluster_name}-alb-controller"
  path        = "/"
  description = "Policy for load balancer controller service"

  policy = file("${path.module}/alb_controller_iam_policy.json")
}

# Role
data "aws_iam_policy_document" "kubernetes_alb_controller_assume" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn] #[data.aws_eks_cluster.eks.identity[0].oidc[0].issuer]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "kubernetes_alb_controller" {
  count              = var.enabled ? 1 : 0
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_alb_controller_assume[0].json
}

resource "aws_iam_role_policy_attachment" "kubernetes_alb_controller" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.kubernetes_alb_controller[0].name
  policy_arn = aws_iam_policy.kubernetes_alb_controller[0].arn
}


# # # provider "kubernetes" {
# # #   host                   = module.eks.cluster_endpoint
# # #   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
# # #   token                  = data.aws_eks_cluster_auth.cluster.token
# # # }

# # # provider "helm" {
# # #   kubernetes = {
# # #     host                   = var.cluster_endpoint
# # #     cluster_ca_certificate = base64decode(var.cluster_ca_cert)
# # #     exec = {
# # #       api_version = "client.authentication.k8s.io/v1beta1"
# # #       args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
# # #       command     = "aws"
# # #     }
# # #   }
# # # }

# # resource "kubernetes_service_account" "service-account" {
# #  metadata {
# #      name      = "aws-load-balancer-controller"
# #      namespace = "kube-system"
# #      labels = {
# #      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
# #      "app.kubernetes.io/component" = "controller"
# #      }
# #      annotations = {
# #      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
# #      "eks.amazonaws.com/sts-regional-endpoints" = "true"
# #      }
# #  }
# # }

# # resource "helm_release" "alb-controller" {
# #  name       = "aws-load-balancer-controller"
# #  repository = "https://aws.github.io/eks-charts"
# #  chart      = "aws-load-balancer-controller"
# #  namespace  = "kube-system"
# #  depends_on = [
# #      kubernetes_service_account.service-account,
# #  ]

# # #  set {
# # #      name  = "region"
# # #      value = var.region
# # #  }

# # #  set {
# # #      name  = "vpcId"
# # #      value = module.vpc.vpc_id
# # #  }

# # #  set {
# # #      name  = "image.repository"
# # #      value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
# # #  }

# #  set {
# #      name  = "serviceAccount.create"
# #      value = "false"
# #  }

# #  set {
# #      name  = "serviceAccount.name"
# #      value = "aws-load-balancer-controller"
# #  }

# #  set {
# #      name  = "clusterName"
# #      value = module.eks.cluster_name
# #  }
# # }