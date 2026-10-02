variable "name" {
  description = "Base name used for resource identifiers (e.g. \"ccms-feasibility\")"
  type        = string
}

variable "config_parameter_name" {
  description = "Name of the SSM parameter holding the agent config. Defaults to the name the CCMS user data scripts fetch (ssm:cloud-watch-config)."
  type        = string
  default     = "cloud-watch-config"
}

variable "agent_config" {
  description = "CloudWatch agent config JSON. Null uses the module's default (CPU, disk, disk IO, memory and swap metrics; /var/log/messages and /var/log/secure to the module's log groups)."
  type        = string
  default     = null
}

variable "target_tag_key" {
  description = "Instance tag used to select which instances get the agent"
  type        = string
  default     = "instance-role"
}

variable "target_tag_values" {
  description = "Values of target_tag_key whose instances get the agent installed and configured"
  type        = list(string)
}

variable "schedule_expression" {
  description = "How often the association re-runs on matching instances (it also runs on creation, on new matching instances, and whenever the config changes)"
  type        = string
  default     = "rate(7 days)"
}

variable "log_retention_days" {
  description = "Retention for the /var/log/messages and /var/log/secure log groups"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
