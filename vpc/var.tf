variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type = string
  default = "rearc-quest-eks"
}

variable "vpc_name" {
   type = string
   default = "rearc-quest-vpc"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}