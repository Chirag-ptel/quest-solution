output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "service_endpoint" {
  value       = aws_lb.lb.dns_name
  description = "The DNS name of the Load Balancer to access the ECS service."
}
