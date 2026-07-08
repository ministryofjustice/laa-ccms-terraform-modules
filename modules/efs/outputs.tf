output "file_system_id" {
  description = "ID of the EFS filesystem"
  value       = aws_efs_file_system.efs.id
}

output "file_system_arn" {
  description = "ARN of the EFS filesystem"
  value       = aws_efs_file_system.efs.arn
}

output "dns_name" {
  description = "DNS name of the EFS filesystem"
  value       = aws_efs_file_system.efs.dns_name
}
