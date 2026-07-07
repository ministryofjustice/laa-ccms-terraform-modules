output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "capacity_provider_names" {
  description = "Map of capacity provider names keyed by the same keys used in var.capacity_providers. Useful for ecs-service placement constraints (SOA)."
  value       = { for k, v in aws_ecs_capacity_provider.ec2 : k => v.name }
}

output "autoscaling_group_arns" {
  description = "Map of ASG ARNs keyed by capacity provider key"
  value       = { for k, v in aws_autoscaling_group.ec2 : k => v.arn }
}
