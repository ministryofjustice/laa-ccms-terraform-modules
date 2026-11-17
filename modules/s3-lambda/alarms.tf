resource "aws_cloudwatch_metric_alarm" "errors" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-lambda-errors"
  alarm_description   = "The ${var.name} Lambda returned errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
