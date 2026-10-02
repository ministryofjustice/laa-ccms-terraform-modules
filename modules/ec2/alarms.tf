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

# Needs the CloudWatch agent's InstanceId + path aggregation (see the cloudwatch-agent module), so the alarm
# doesn't depend on fstype, device or AMI dimensions
resource "aws_cloudwatch_metric_alarm" "disk_used_high" {
  for_each = var.alarms == null ? toset([]) : toset(var.alarms.disk_paths)

  alarm_name          = "${var.name}-disk-used-${each.value == "/" ? "root" : replace(trim(each.value, "/"), "/", "-")}"
  alarm_description   = "${each.value} on ${var.name} is at or above ${var.alarms.disk_used_threshold_percent}% used for 2 minutes"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.alarms.disk_used_threshold_percent
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.ec2.id
    path       = each.value
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
