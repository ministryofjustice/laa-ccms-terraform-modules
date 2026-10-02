resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-ec2-status-check-failed"
  alarm_description   = "The ${var.name} EC2 instance has failed a status check for 5 minutes"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.ec2.id
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
