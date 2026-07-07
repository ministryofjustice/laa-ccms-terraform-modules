resource "aws_cloudwatch_log_group" "db" {
  for_each = toset(var.cloudwatch_log_exports)

  name              = "/aws/rds/instance/${var.name}/${each.key}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-rds-${each.key}"
  })
}

resource "aws_sns_topic" "maintenance" {
  name = "${var.name}-rds-maintenance"

  tags = merge(var.tags, {
    Name = "${var.name}-rds-maintenance"
  })
}

resource "aws_db_event_subscription" "db" {
  name      = "${var.name}-rds-events"
  sns_topic = aws_sns_topic.maintenance.arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.db.id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "maintenance",
    "notification",
    "recovery",
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-rds-events"
  })
}
