variable "name" {
  description = "Base name used for all resource identifiers"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach the ALB to"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener"
  type        = string
}

variable "target_port" {
  description = "Port the target instances/IPs listen on"
  type        = number
}

variable "target_type" {
  description = "Target group target type. Use \"ip\" for awsvpc-mode ECS tasks, \"instance\" for bridge-mode"
  type        = string
  default     = "instance"
}

variable "health_check" {
  description = "Health check configuration for the target group"
  type = object({
    path                = optional(string, "/health")
    matcher             = optional(string, "200")
    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 120)
    timeout             = optional(number, 5)
  })
  default = {}
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
  default     = true
}

variable "deregistration_delay" {
  description = "Seconds to wait before deregistering a target"
  type        = number
  default     = 30
}

variable "stickiness" {
  description = "Session stickiness configuration for the target group"
  type = object({
    enabled  = optional(bool, false)
    duration = optional(number, 3600)
  })
  default = {}
}

variable "access_logs" {
  description = "Access log delivery for the ALB. The bucket policy must allow ELB log delivery. Null disables access logging."
  type = object({
    bucket  = string
    prefix  = optional(string)
    enabled = optional(bool, true)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alarms" {
  description = "CloudWatch alarms for the ALB, sent to topic_arn on alarm and on recovery. Null creates no alarms. Thresholds default to the values used by the original CCMS stacks."
  type = object({
    topic_arn         = string
    min_healthy_hosts = optional(number, 1)  # alarm when fewer healthy targets than this
    max_5xx_count     = optional(number, 10) # alarm when more ELB 5XX responses than this per minute, 3 minutes running
  })
  default = null
}
