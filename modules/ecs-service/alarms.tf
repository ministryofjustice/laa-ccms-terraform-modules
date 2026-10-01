locals {
  # cluster_id is the cluster ARN (arn:aws:ecs:<region>:<account>:cluster/<name>); alarm dimensions need the name
  cluster_name = reverse(split("/", var.cluster_id))[0]

  alarm_dimensions = {
    ClusterName = local.cluster_name
    ServiceName = aws_ecs_service.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "running_tasks" {
  count = var.alarms != null && var.desired_count > 0 ? 1 : 0

  alarm_name          = "${var.name}-ecs-running-tasks-low"
  alarm_description   = "Fewer than ${var.desired_count} ${var.name} ECS tasks running"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "RunningTaskCount"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.desired_count
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  dimensions          = local.alarm_dimensions

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-ecs-cpu-high"
  alarm_description   = "${var.name} ECS service CPU at or above ${var.alarms.cpu_threshold_percent}% for 5 minutes"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.alarms.cpu_threshold_percent
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = local.alarm_dimensions

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-ecs-memory-high"
  alarm_description   = "${var.name} ECS service memory above ${var.alarms.memory_threshold_percent}% for 5 minutes"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.alarms.memory_threshold_percent
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = local.alarm_dimensions

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
