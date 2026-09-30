resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.name}-guardduty-findings"
  description = "GuardDuty findings in this account, sent to the alerts topic"
  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "guardduty_findings" {
  rule = aws_cloudwatch_event_rule.guardduty_findings.name
  arn  = aws_sns_topic.alerts.arn
}

resource "aws_cloudwatch_event_rule" "certificate_expiry" {
  name        = "${var.name}-certificate-expiry"
  description = "ACM certificates approaching expiry, expired or failing renewal, sent to the alerts topic"
  event_pattern = jsonencode({
    source        = ["aws.acm"]
    "detail-type" = ["ACM Certificate Approaching Expiration", "ACM Certificate Expired", "ACM Certificate Renewal Failed"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "certificate_expiry" {
  rule = aws_cloudwatch_event_rule.certificate_expiry.name
  arn  = aws_sns_topic.alerts.arn
}
