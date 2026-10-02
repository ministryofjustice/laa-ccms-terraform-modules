resource "aws_cloudwatch_metric_alarm" "burst_credit_balance_low" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-efs-burst-credits-low"
  alarm_description   = "${var.name} EFS burst credit balance below ${floor(var.alarms.min_burst_credit_balance / 1073741824)}GiB. Throughput will drop to the baseline when credits run out: https://docs.aws.amazon.com/efs/latest/ug/performance.html"
  namespace           = "AWS/EFS"
  metric_name         = "BurstCreditBalance"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alarms.min_burst_credit_balance
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FileSystemId = aws_efs_file_system.efs.id
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
