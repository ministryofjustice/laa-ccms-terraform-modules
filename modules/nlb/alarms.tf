# Alarms on any unhealthy target rather than a healthy-target minimum: NLB cross-zone load balancing is off by
# default, so each zone's node only counts its own zone's targets and a per-node healthy count is misleading.
# Missing tasks are caught by the ecs-service running-tasks alarm.
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-nlb-unhealthy-hosts"
  alarm_description   = "Unhealthy targets behind the ${var.name} NLB for 3 minutes"
  namespace           = "AWS/NetworkELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.nlb.arn_suffix
    TargetGroup  = aws_lb_target_group.nlb.arn_suffix
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
