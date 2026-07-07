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
  description = "Port the target instances listen on"
  type        = number
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
