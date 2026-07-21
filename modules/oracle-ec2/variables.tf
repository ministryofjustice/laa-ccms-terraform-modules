variable "name" {
  description = "Base name used for the EC2 instance tag"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID in which to launch the instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
}

variable "iam_role_name" {
  description = "Name for the IAM role and instance profile created by this module. Required when instance_profile_name is not set."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Name of an existing IAM instance profile to attach. When set, this module skips IAM resource creation and uses the supplied profile."
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "List of additional IAM managed policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Base64-encoded user data script"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "Enable EBS optimised mode"
  type        = bool
  default     = false
}

variable "cpu_core_count" {
  description = "Number of CPU cores. Leave null to use the instance type default."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "Threads per CPU core. Only used when cpu_core_count is set."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
