variable "name" {
  description = "Base name for all WAF resources"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to associate the WAF with"
  type        = string
}

variable "ip_allowlist" {
  description = "List of CIDR blocks that are always allowed through (e.g. workspace IPs, private subnets)"
  type        = list(string)
  default     = []
}

variable "managed_rule_overrides" {
  description = "Rule action overrides for the AWS Managed Common Rule Set. Leave empty to use all rules at their default action."
  type = list(object({
    name   = string
    action = string # "count" or "allow"
  }))
  default = []
}

variable "log_retention_days" {
  description = "Number of days to retain WAF logs in CloudWatch"
  type        = number
  default     = 180
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
