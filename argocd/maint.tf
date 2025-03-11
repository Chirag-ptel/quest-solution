provider "aws" {
  region  = var.region
}

terraform {
  required_providers {
    argocd = {
      source = "jojand/argocd"
      version = "2.3.2"
    }
  }
}

provider "argocd" {
  server_addr = "${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
  username    = var.argo_user
  password    = var.argo_pass
  insecure    = true
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name ]
    command     = "aws"
  }
}

terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest/argocd/terraform.tfstate"
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

resource "helm_release" "argocd" {
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace
  create_namespace = true
  # upgrade_install = true

  values = [file("${path.module}/values.yaml")]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"  # Replace with the actual service name
    namespace = var.namespace
  }
}

resource "argocd_repository" "private" {
  repo            = "https://github.com/Chirag-ptel/quest-raw.git"
  username        = var.repo_user
  password        = var.repo_pass
  insecure        = true
  type            = "git"
}

