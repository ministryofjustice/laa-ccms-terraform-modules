variable "name" {
  description = "Name for the ECS task definition family and service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster to deploy the service into"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role used by the ECS agent to pull images and retrieve secrets"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role assumed by the running container (for AWS API access). Leave null if not needed."
  type        = string
  default     = null
}

variable "container_definitions" {
  description = "JSON string of container definitions. Render via templatefile() in the calling module."
  type        = string
}

variable "cpu" {
  description = "CPU units reserved for the task"
  type        = number
}

variable "memory" {
  description = "Memory (MiB) reserved for the task"
  type        = number
}

variable "desired_count" {
  description = "Number of task instances to run"
  type        = number
}

variable "network_mode" {
  description = "Docker networking mode for the task (bridge or awsvpc)"
  type        = string
  default     = "bridge"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks after a task starts. Only applies when load_balancer is set."
  type        = number
  default     = 120
}

variable "ordered_placement_strategy" {
  description = "Ordered list of placement strategies for distributing tasks across instances"
  type = list(object({
    type  = string
    field = string
  }))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  ]
}

variable "placement_constraints" {
  description = "Placement constraints to control which instances tasks can run on (e.g. for SOA server attribute filtering)"
  type = list(object({
    type       = string
    expression = optional(string, null)
  }))
  default = []
}

variable "load_balancer" {
  description = "Load balancer target group to attach to the service. Set to null for services without a load balancer."
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
