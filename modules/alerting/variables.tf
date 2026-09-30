variable "name" {
  description = "Base name used for all resource identifiers (e.g. \"ccms-feasibility\")"
  type        = string
}

variable "suppressed_alarm_prefixes" {
  description = "CloudWatch alarms whose name starts with one of these prefixes are not sent to Slack during the suppression window. Empty disables suppression."
  type        = list(string)
  default     = []
}

variable "suppression_time_start" {
  description = "Start of the daily suppression window (HH:MM, UTC)"
  type        = string
  default     = "19:00"
}

variable "suppression_time_end" {
  description = "End of the daily suppression window (HH:MM, UTC)"
  type        = string
  default     = "07:00"
}

variable "notify_unrecognised" {
  description = "Post a generic Slack message for events the notifier doesn't recognise, rather than dropping them"
  type        = bool
  default     = true
}

variable "debug" {
  description = "Enable debug logging in the Slack notifier Lambda"
  type        = bool
  default     = false
}

variable "dlq_alert_emails" {
  description = "Email addresses notified when a Slack notification fails and is dead-lettered. Each address must confirm the SNS subscription."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Retention for the Slack notifier Lambda's log group"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
