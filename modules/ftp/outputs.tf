output "function_name" {
  description = "Name of the FTP Lambda function"
  value       = aws_lambda_function.ftp_lambda.function_name
}

output "function_arn" {
  description = "ARN of the FTP Lambda function"
  value       = aws_lambda_function.ftp_lambda.arn
}
