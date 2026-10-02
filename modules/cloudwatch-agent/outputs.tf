output "agent_policy_arn" {
  description = "AWS managed policy the instance roles need so the agent can publish metrics and logs"
  value       = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

output "config_parameter_name" {
  description = "SSM parameter holding the agent config"
  value       = aws_ssm_parameter.cloudwatch_agent.name
}

output "log_group_names" {
  description = "Log groups the agent writes /var/log/messages and /var/log/secure to"
  value       = { messages = local.messages_log_group, secure = local.secure_log_group }
}

output "association_id" {
  description = "ID of the SSM association that installs and configures the agent"
  value       = aws_ssm_association.cloudwatch_agent.association_id
}
