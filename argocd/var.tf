variable "region" {
  type        = string
  description = "AWS region where secrets are stored."
  default     = "ap-south-1"
}

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
  default     = "argocd"
  description = "Helm chart name to be installed"
}

variable "helm_chart_release_name" {
  type        = string
  default     = "argo-cd"
  description = "Helm release name"
}

variable "helm_chart_version" {
  type        = string
  default     = "7.8.9"
  description = "ALB Controller Helm chart version."
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
  description = "helm chart repository name."
}

variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Kubernetes namespace to deploy helm chart."
}

variable "repo_user" {
  type        = string
  default     = "Chirag-ptel"
  description = "Argocd repo username"
}

variable "repo_pass" {
  type        = string
  description = "Argocd repo token"
  sensitive   = true
}

variable "argo_user" {
  type        = string
  default     = "admin"
  description = "Argocd username"
}

variable "argo_pass" {
  type        = string
  description = "Argocd password"
  sensitive   = true
}