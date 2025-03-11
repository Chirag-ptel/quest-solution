
variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "rearc-quest-eks"
}

variable "aws_region" {
  type        = string
  description = "AWS region where secrets are stored."
  default     = "ap-south-1"
}

variable "cluster_identity_oidc_issuer" {
  type        = string
  description = "The OIDC Identity issuer for the cluster."
  default     = "https://oidc.eks.ap-south-1.amazonaws.com/id/6A3B669396DE258BD984D86D44BB4C41"
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
  default     = "arn:aws:iam::992382391803:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/6A3B669396DE258BD984D86D44BB4C41"
}

variable "helm_chart_name" {
  type        = string
  default     = "secrets-store-csi-driver"
  description = "Helm chart name to be installed"
}

variable "helm_chart_name_secret_provider" {
  type        = string
  default     = "secrets-store-csi-driver-provider-aws"
  description = "Helm chart name to be installed"
}

variable "helm_chart_release_name" {
  type        = string
  default     = "secrets-store-csi-driver"
  description = "Helm release name"
}

variable "helm_chart_release_name_secret_provider" {
  type        = string
  default     = "secrets-store-csi-driver-provider-aws"
  description = "Helm release name"
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  description = "helm chart repository name."
}

variable "helm_chart_repo_secret_provider" {
  type        = string
  default     = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  description = "helm chart repository name."
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy helm chart."
}

variable "quest_secret" {
  default = {
    SECRET_WORD = "IAMBATMAN"
  }

  type = map(string)
  sensitive = true
}

