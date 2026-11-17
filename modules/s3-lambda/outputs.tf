output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "role_arn" {
  description = "ARN of the Lambda's IAM role"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the Lambda's IAM role — attach further policies to it if needed"
  value       = aws_iam_role.lambda.name
}

output "security_group_id" {
  description = "ID of the Lambda's security group — add further rules to it if needed, or reference it from other security groups"
  value       = aws_security_group.lambda.id
}

output "log_group_name" {
  description = "Name of the Lambda's CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}
