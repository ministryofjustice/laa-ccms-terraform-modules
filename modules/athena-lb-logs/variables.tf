variable "name" {
  description = "Base name used for the Athena workgroup and Glue database (e.g. \"ccms-feasibility\")"
  type        = string
}

variable "bucket_name" {
  description = "Existing S3 bucket the load balancers write access logs to. Athena query results are written to its athena-results/ prefix."
  type        = string
}

variable "alb_log_prefixes" {
  description = "One bucket prefix (directory) per ALB. Each must match the access_logs prefix passed to the alb module, and becomes a value of the \"lb\" partition in the alb_access_logs table. Empty skips the table."
  type        = list(string)
  default     = []
}

variable "nlb_log_prefixes" {
  description = "One bucket prefix (directory) per NLB. Each must match the access_logs prefix passed to the nlb module, and becomes a value of the \"lb\" partition in the nlb_access_logs table. Empty skips the table."
  type        = list(string)
  default     = []
}

variable "projection_start_date" {
  description = "Earliest day (yyyy/MM/dd) covered by the Athena day partition"
  type        = string
  default     = "2026/01/01"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
