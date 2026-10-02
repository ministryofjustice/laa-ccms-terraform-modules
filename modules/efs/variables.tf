variable "name" {
  description = "Base name for all EFS resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets (one per AZ)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to attach to mount targets"
  type        = list(string)
}

variable "kms_key_id" {
  description = "ARN of the KMS key used to encrypt the filesystem"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alarms" {
  description = "CloudWatch alarms for the file system, sent to topic_arn on alarm and on recovery. Null creates no alarms. Thresholds default to the values used by the original CCMS stacks."
  type = object({
    topic_arn                = string
    min_burst_credit_balance = optional(number, 10737418240) # bytes (10GiB); alarm when burst credits drop below this
  })
  default = null
}
