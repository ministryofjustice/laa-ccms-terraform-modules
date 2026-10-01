resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-alb-unhealthy-hosts"
  alarm_description   = "Fewer than ${var.alarms.min_healthy_hosts} healthy targets behind the ${var.name} ALB"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Average"
  period              = 240
  evaluation_periods  = 1
  threshold           = var.alarms.min_healthy_hosts
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
    TargetGroup  = aws_lb_target_group.alb.arn_suffix
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elb_5xx" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-alb-5xx-errors"
  alarm_description   = "More than ${var.alarms.max_5xx_count} 5XX responses a minute from the ${var.name} ALB for 3 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 3
  threshold           = var.alarms.max_5xx_count
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
