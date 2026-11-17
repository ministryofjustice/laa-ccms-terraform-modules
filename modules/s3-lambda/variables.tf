variable "name" {
  description = "Name of the Lambda function. Also the base name for its IAM role, security group and log group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Lambda security group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to run the Lambda in"
  type        = list(string)
}

variable "filename" {
  description = "Local path to the initial deployment package. Set this or s3_bucket/s3_key. The code is deployed outside Terraform afterwards, so changes to the package are ignored."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket holding the initial deployment package, used with s3_key in place of filename"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the initial deployment package, used with s3_bucket in place of filename"
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint, e.g. \"example.HelloWorldHandler\" for Java. Changes are ignored after creation, alongside the code."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime, e.g. \"java25\" or \"python3.13\""
  type        = string
}

variable "timeout" {
  description = "Seconds the function can run before it is stopped"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Memory (MiB) available to the function"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables passed to the function"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
  description = "Name of the bucket whose uploads trigger the function. The module owns the bucket's notification configuration, so the bucket must have no other aws_s3_bucket_notification."
  type        = string
}

variable "trigger" {
  description = "Which bucket events invoke the function"
  type = object({
    events        = optional(list(string), ["s3:ObjectCreated:*"])
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  })
  default = {}
}

variable "bucket_actions" {
  description = "S3 actions the function is allowed on the bucket and its objects"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:GetObjectTagging",
    "s3:ListBucket",
    "s3:PutObject",
    "s3:PutObjectTagging",
    "s3:DeleteObject",
  ]
}

variable "secret_arns" {
  description = "Secrets Manager secret ARNs the function can read"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "KMS key ARNs the function can encrypt and decrypt with, e.g. the keys for the bucket and the secrets"
  type        = list(string)
  default     = []
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks the function can reach on HTTPS (443). Add further rules to the security_group_id output if it needs anything else."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "log_retention_days" {
  description = "Number of days to retain the function's logs in CloudWatch"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alarms" {
  description = "CloudWatch alarms for the function, sent to topic_arn on alarm and on recovery. Null creates no alarms."
  type = object({
    topic_arn = string
  })
  default = null
}
