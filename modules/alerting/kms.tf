data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Encrypts the alert topics. CloudWatch alarms and EventBridge need to use the key to publish to them.
resource "aws_kms_key" "alerts" {
  description             = "${var.name} alerts SNS topic encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.alerts_kms.json

  tags = merge(var.tags, {
    Name = "${var.name}-alerts"
  })
}

resource "aws_kms_alias" "alerts" {
  name          = "alias/${var.name}-alerts"
  target_key_id = aws_kms_key.alerts.key_id
}

# checkov:skip=CKV_AWS_356: KMS key policies require Resource="*"; constrained via principals
data "aws_iam_policy_document" "alerts_kms" {
  statement {
    sid       = "AllowAccountAdmins"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAlertPublishersUseOfTheKey"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com", "events.amazonaws.com"]
    }
  }
}
