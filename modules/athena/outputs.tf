output "athena_workgroup_name" {
  description = "Athena workgroup to run access log queries in"
  value       = aws_athena_workgroup.athena.name
}

output "glue_database_name" {
  description = "Glue/Athena database holding the access log tables"
  value       = aws_glue_catalog_database.athena.name
}

output "table_names" {
  description = "Access log tables created, keyed by load balancer type (alb/nlb)"
  value       = { for k, t in aws_glue_catalog_table.athena : k => t.name }
}
