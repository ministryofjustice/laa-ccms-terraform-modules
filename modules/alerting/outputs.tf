output "alerts_topic_arn" {
  description = "ARN of the alerts SNS topic — use as alarm_actions/ok_actions on CloudWatch alarms"
  value       = aws_sns_topic.alerts.arn
}

output "alerts_topic_name" {
  description = "Name of the alerts SNS topic — for looking it up from other stacks"
  value       = aws_sns_topic.alerts.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting the alert topics"
  value       = aws_kms_key.alerts.arn
}

output "slack_notifier_function_name" {
  description = "Name of the Slack notifier Lambda — subscribe other SNS topics to it (plus an aws_lambda_permission)"
  value       = aws_lambda_function.slack_notifier.function_name
}

output "slack_notifier_function_arn" {
  description = "ARN of the Slack notifier Lambda"
  value       = aws_lambda_function.slack_notifier.arn
}

output "slack_webhooks_secret_name" {
  description = "Secrets Manager secret holding the Slack webhook URLs"
  value       = aws_secretsmanager_secret.slack_webhooks.name
}
