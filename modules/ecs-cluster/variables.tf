variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "capacity_providers" {
  description = <<-EOT
    Map of capacity providers to create. Each entry creates a launch template, ASG, and ECS capacity provider.
    Use a single key (e.g. "default") for most apps. SOA uses two keys ("admin" and "managed").

    user_data should be base64-encoded. If omitted, a minimal ECS config is generated automatically.
  EOT
  type = map(object({
    instance_type         = string
    image_id              = string
    min_size              = number
    max_size              = number
    desired_capacity      = number
    instance_profile_name = string
    security_group_ids    = list(string)
    subnet_ids            = list(string)
    root_volume_size      = optional(number, 30)
    ebs_encrypted         = optional(bool, true)
    kms_key_id            = optional(string, null)
    user_data             = optional(string, null)
  }))
}
