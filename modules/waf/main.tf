resource "aws_wafv2_ip_set" "allowlist" {
  count = length(var.ip_allowlist) > 0 ? 1 : 0

  name               = "${var.name}-ip-allowlist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ip_allowlist

  tags = merge(var.tags, {
    Name = "${var.name}-ip-allowlist"
  })
}

resource "aws_wafv2_web_acl" "waf" {
  name  = "${var.name}-waf"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  # Always-on: allow trusted IPs before managed rules run
  dynamic "rule" {
    for_each = length(var.ip_allowlist) > 0 ? [1] : []
    content {
      name     = "AllowListedIPs"
      priority = 10

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowlist[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-allowed-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.enable_managed_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 20

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"

          dynamic "rule_action_override" {
            for_each = var.managed_rule_overrides
            content {
              name = rule_action_override.value.name
              action_to_use {
                dynamic "count" {
                  for_each = rule_action_override.value.action == "count" ? [1] : []
                  content {}
                }
                dynamic "allow" {
                  for_each = rule_action_override.value.action == "allow" ? [1] : []
                  content {}
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-common-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-waf"
  })
}

resource "aws_wafv2_web_acl_association" "waf" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}

# WAF log group name must start with aws-waf-logs-
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "aws-waf-logs-${var.name}"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "waf" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.waf.arn
}
