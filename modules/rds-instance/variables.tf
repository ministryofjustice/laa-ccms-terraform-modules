variable "name" {
  description = "Base name used for all resource identifiers (e.g. ccms-edrms-feasibility-tds)"
  type        = string
}

variable "engine" {
  description = "RDS engine (e.g. oracle-se2, mysql)"
  type        = string
}

variable "engine_version" {
  description = "Full engine version string (e.g. 19.0.0.0.ru-2024-01.rur-2024-01.r1, 8.0.35)"
  type        = string
}

variable "major_engine_version" {
  description = "Major engine version for the option group (e.g. '19' for Oracle SE2, '8.0' for MySQL)"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class (e.g. db.t3.small, db.m5.large)"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "Provisioned IOPS. Only applies when storage_type is io1 or gp3 with IOPS"
  type        = number
  default     = null
}

variable "db_name" {
  description = "Name of the database to create on the instance"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Port the database listens on (1521 for Oracle, 3306 for MySQL)"
  type        = number
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach to the RDS instance"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "kms_key_id" {
  description = "ARN of the KMS key for storage encryption"
  type        = string
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on deletion"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 30
}

variable "maintenance_window" {
  description = "Preferred maintenance window (e.g. Mon:00:00-Mon:03:00)"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "Preferred backup window (e.g. 03:00-06:00)"
  type        = string
  default     = "03:00-06:00"
}

variable "character_set_name" {
  description = "Character set for the database. Oracle only (e.g. AL32UTF8)"
  type        = string
  default     = null
}

variable "license_model" {
  description = "License model for the database. Oracle only (bring-your-own-license or license-included)"
  type        = string
  default     = null
}

variable "options" {
  description = "List of option group options. Leave empty for MySQL or Oracle instances that do not need custom options"
  type = list(object({
    option_name = string
    port        = optional(number)
    version     = optional(string)
  }))
  default = []
}

variable "cloudwatch_log_exports" {
  description = "Log types to export to CloudWatch. Oracle: [alert, audit, listener]. MySQL: [error, general, slowquery]"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain RDS CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
