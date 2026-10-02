resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each = var.alarms == null ? {} : var.capacity_providers

  alarm_name          = "${var.cluster_name}-${each.key}-ec2-status-check-failed"
  alarm_description   = "An EC2 instance in the ${var.cluster_name} ${each.key} cluster has failed a status check for 5 minutes"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2[each.key].name
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
