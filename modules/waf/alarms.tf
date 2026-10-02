data "aws_region" "current" {}

# WAFv2 publishes BlockedRequests with Region, Rule and WebACL dimensions; Rule = "ALL" is the total across rules
resource "aws_cloudwatch_metric_alarm" "blocked_requests_high" {
  count = var.alarms == null ? 0 : 1

  alarm_name          = "${var.name}-waf-blocked-requests-high"
  alarm_description   = "More than ${var.alarms.max_blocked_requests} requests a minute blocked by the ${var.name} WAF for 5 minutes. Possible attack, or the IP allowlist or managed rules are blocking real users"
  namespace           = "AWS/WAFV2"
  metric_name         = "BlockedRequests"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.alarms.max_blocked_requests
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.waf.name
    Region = data.aws_region.current.id
    Rule   = "ALL"
  }

  alarm_actions = [var.alarms.topic_arn]
  ok_actions    = [var.alarms.topic_arn]

  tags = var.tags
}
