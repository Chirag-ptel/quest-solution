variable "region" {
  default = "ap-south-1"
}

variable "ecs_cluster_name" {
  default = "quest-cluster"
}

variable "ecs_desired_count" {
  default = 1
}

variable "ecs_service_name" {
  default = "quest-service"
}

variable "lb_name" {
  default = "quest-lb"
}

variable "tg_name" {
  default = "quest-tg"
}

