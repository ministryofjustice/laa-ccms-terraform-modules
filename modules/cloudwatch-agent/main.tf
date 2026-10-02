# Installs and configures the CloudWatch agent on running instances through SSM, so no rebuild or user data
# change is needed. Instance roles need AmazonSSMManagedInstanceCore and CloudWatchAgentServerPolicy (see the
# agent_policy_arn output).

locals {
  messages_log_group = "cwagent-var-log-messages"
  secure_log_group   = "cwagent-var-log-secure"

  agent_config = coalesce(var.agent_config, templatefile("${path.module}/templates/agent_config.json.tpl", {
    messages_log_group = local.messages_log_group
    secure_log_group   = local.secure_log_group
  }))
}

resource "aws_cloudwatch_log_group" "cloudwatch_agent" {
  for_each = toset([local.messages_log_group, local.secure_log_group])

  name              = each.value
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = each.value
  })
}

resource "aws_ssm_parameter" "cloudwatch_agent" {
  name        = var.config_parameter_name
  description = "CloudWatch agent config for ${var.name} instances"
  type        = "String"
  value       = local.agent_config

  tags = merge(var.tags, {
    Name = var.config_parameter_name
  })
}

resource "aws_ssm_document" "cloudwatch_agent" {
  name            = "${var.name}-install-and-configure-cloudwatch-agent"
  document_type   = "Command"
  document_format = "YAML"
  content         = file("${path.module}/templates/install-and-configure.yaml")

  tags = merge(var.tags, {
    Name = "${var.name}-install-and-configure-cloudwatch-agent"
  })
}

resource "aws_ssm_association" "cloudwatch_agent" {
  name                = aws_ssm_document.cloudwatch_agent.name
  association_name    = "${var.name}-cloudwatch-agent"
  schedule_expression = var.schedule_expression

  parameters = {
    configParameterName = aws_ssm_parameter.cloudwatch_agent.name
    configHash          = sha256(local.agent_config)
  }

  targets {
    key    = "tag:${var.target_tag_key}"
    values = var.target_tag_values
  }

  depends_on = [aws_cloudwatch_log_group.cloudwatch_agent]
}
