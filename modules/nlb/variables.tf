variable "name" {
  description = "Base name used for all resource identifiers"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach the NLB to"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the NLB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the TLS (443) listener"
  type        = string
}

variable "target_port" {
  description = "Port the target instances/IPs listen on. Also used as the port for the third (passthrough) listener"
  type        = number
}

variable "target_type" {
  description = "Target group target type. Use \"ip\" for awsvpc-mode ECS tasks, \"instance\" for bridge-mode"
  type        = string
  default     = "ip"
}

variable "target_group_protocol" {
  description = "Protocol used from the NLB to the target. \"TCP\" for a plaintext backend, \"TLS\" for backend re-encryption (end-to-end TLS, terminated by the target itself). Also used for the direct target_port listener."
  type        = string
  default     = "TCP"

  validation {
    condition     = contains(["TCP", "TLS"], var.target_group_protocol)
    error_message = "target_group_protocol must be \"TCP\" or \"TLS\"."
  }
}

variable "enable_port_80_listener" {
  description = "Whether to create the plaintext port-80 listener. Set to false for backends that no longer accept unencrypted traffic."
  type        = bool
  default     = true
}

variable "health_check" {
  description = "Health check configuration for the target group"
  type = object({
    protocol            = optional(string, "TCP")
    path                = optional(string, null)
    port                = optional(number, null)
    matcher             = optional(string, null)
    healthy_threshold   = optional(number, 3)
    unhealthy_threshold = optional(number, 3)
    interval            = optional(number, 30)
    timeout             = optional(number, 10)
  })
  default = {}
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the NLB."
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
