output "db_instance_id" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.db.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}

output "db_endpoint" {
  description = "Connection endpoint of the RDS instance (host:port)"
  value       = aws_db_instance.db.endpoint
}

output "db_address" {
  description = "Hostname of the RDS instance (without port)"
  value       = aws_db_instance.db.address
}

output "db_port" {
  description = "Port the RDS instance listens on"
  value       = aws_db_instance.db.port
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for RDS maintenance notifications"
  value       = aws_sns_topic.maintenance.arn
}
