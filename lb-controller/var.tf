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

variable "region" {
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

variable "service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "ALB Controller service account name"
}

variable "helm_chart_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "ALB Controller Helm chart name to be installed"
}

variable "helm_chart_release_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "Helm release name"
}

variable "helm_chart_version" {
  type        = string
  default     = "1.5.3"
  description = "ALB Controller Helm chart version."
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://aws.github.io/eks-charts"
  description = "ALB Controller repository name."
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy ALB Controller Helm chart."
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable."
}

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}