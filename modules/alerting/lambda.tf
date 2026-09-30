# Slack notifier: posts alerts from the alerts topic to Slack. Source is in lambda/slack_notifier

locals {
  slack_notifier_name = "${var.name}-slack-notifier"
}

resource "aws_secretsmanager_secret" "slack_webhooks" {
  name        = "${var.name}-slack-webhooks"
  description = "Slack webhook URLs for ${var.name} alerts: slack_channel_webhook (CloudWatch/ACM), slack_channel_webhook_guardduty, slack_channel_webhook_s3"

  tags = merge(var.tags, {
    Name = "${var.name}-slack-webhooks"
  })
}

resource "aws_secretsmanager_secret_version" "slack_webhooks" {
  secret_id = aws_secretsmanager_secret.slack_webhooks.id
  secret_string = jsonencode({
    slack_channel_webhook           = ""
    slack_channel_webhook_guardduty = ""
    slack_channel_webhook_s3        = ""
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "archive_file" "slack_notifier" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/slack_notifier"
  output_path = "${path.module}/lambda/slack_notifier.zip"
  excludes    = ["pyproject.toml", "test_lambda_function.py"]
}

resource "aws_cloudwatch_log_group" "slack_notifier" {
  name              = "/aws/lambda/${local.slack_notifier_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_lambda_function" "slack_notifier" {
  function_name    = local.slack_notifier_name
  description      = "Posts ${var.name} CloudWatch, GuardDuty, S3 and ACM alerts to Slack"
  filename         = data.archive_file.slack_notifier.output_path
  source_code_hash = data.archive_file.slack_notifier.output_base64sha256
  role             = aws_iam_role.slack_notifier.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30

  environment {
    variables = {
      SECRET_NAME             = aws_secretsmanager_secret.slack_webhooks.name
      DEBUG                   = tostring(var.debug)
      METRICS_ENABLED         = "true"
      METRICS_NAMESPACE       = "${var.name}/SlackNotifier"
      NOTIFY_UNRECOGNISED     = tostring(var.notify_unrecognised)
      SUPPRESSED_ENVIRONMENTS = join(",", var.suppressed_alarm_prefixes)
      SUPPRESSION_TIME_START  = var.suppression_time_start
      SUPPRESSION_TIME_END    = var.suppression_time_end
    }
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.slack_notifier]

  tags = merge(var.tags, {
    Name = local.slack_notifier_name
  })
}

resource "aws_lambda_permission" "slack_notifier_alerts_topic" {
  statement_id  = "AllowExecutionFromAlertsTopic"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

# IAM

resource "aws_iam_role" "slack_notifier" {
  name = local.slack_notifier_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = merge(var.tags, {
    Name = local.slack_notifier_name
  })
}

resource "aws_iam_role_policy" "slack_notifier" {
  name = local.slack_notifier_name
  role = aws_iam_role.slack_notifier.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = [aws_secretsmanager_secret.slack_webhooks.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = ["${aws_cloudwatch_log_group.slack_notifier.arn}:*"]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = [aws_sqs_queue.slack_notifier_dlq.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "slack_notifier_xray" {
  role       = aws_iam_role.slack_notifier.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Dead-letter queue: notifications that fail to post to Slack land here instead of being lost

resource "aws_sqs_queue" "slack_notifier_dlq" {
  name                      = "${local.slack_notifier_name}-dlq"
  message_retention_seconds = 1209600 # 14 days
  sqs_managed_sse_enabled   = true

  tags = merge(var.tags, {
    Name = "${local.slack_notifier_name}-dlq"
  })
}

resource "aws_lambda_function_event_invoke_config" "slack_notifier" {
  function_name                = aws_lambda_function.slack_notifier.function_name
  maximum_retry_attempts       = 0
  maximum_event_age_in_seconds = 3600

  destination_config {
    on_failure {
      destination = aws_sqs_queue.slack_notifier_dlq.arn
    }
  }

  depends_on = [aws_iam_role_policy.slack_notifier]
}

# The DLQ alarm can't go to Slack (Slack delivery is what failed), so it has its own topic with email subscribers
resource "aws_sns_topic" "slack_notifier_dlq_alerts" {
  name              = "${local.slack_notifier_name}-dlq-alerts"
  kms_master_key_id = aws_kms_key.alerts.arn

  tags = merge(var.tags, {
    Name = "${local.slack_notifier_name}-dlq-alerts"
  })
}

resource "aws_sns_topic_subscription" "slack_notifier_dlq_alerts" {
  for_each = toset(var.dlq_alert_emails)

  topic_arn = aws_sns_topic.slack_notifier_dlq_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "slack_notifier_dlq_not_empty" {
  alarm_name          = "${local.slack_notifier_name}-dlq-not-empty"
  alarm_description   = "A ${var.name} alert could not be delivered to Slack and was dead-lettered to ${aws_sqs_queue.slack_notifier_dlq.name}"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions          = { QueueName = aws_sqs_queue.slack_notifier_dlq.name }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.slack_notifier_dlq_alerts.arn]

  tags = var.tags
}
