locals {
  free_storage_threshold_bytes = var.alarms == null ? 0 : var.allocated_storage * var.alarms.free_storage_percent / 100 * 1024 * 1024 * 1024
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-rds-cpu-high"
  alarm_description   = "${var.name} RDS CPU above ${var.alarms.cpu_threshold_percent}% for 5 minutes"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.alarms.cpu_threshold_percent
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "free_storage_low" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-rds-free-storage-low"
  alarm_description   = "${var.name} RDS free storage below ${var.alarms.free_storage_percent}% of ${var.allocated_storage}GB"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  threshold           = local.free_storage_threshold_bytes
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_low" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-rds-freeable-memory-low"
  alarm_description   = "${var.name} RDS freeable memory below ${floor(var.alarms.freeable_memory_threshold / 1000000)}MB for 5 minutes"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.alarms.freeable_memory_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}

# RDS events (failover, failure, maintenance etc.) also go to the alerts topic, so they reach Slack.
# The topic must allow events.rds.amazonaws.com to publish (the alerting module does).
resource "aws_db_event_subscription" "alerts" {
  count = var.alarms == null ? 0 : 1

  name      = "${var.name}-rds-alerts"
  sns_topic = var.alarms.topic_arn

  source_type      = "db-instance"
  source_ids       = [aws_db_instance.db.identifier]
  event_categories = aws_db_event_subscription.db.event_categories

  tags = merge(var.tags, {
    Name = "${var.name}-rds-alerts"
  })
}
