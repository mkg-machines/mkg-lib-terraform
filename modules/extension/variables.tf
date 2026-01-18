variable "extension_name" {
  description = "Name der Extension (z.B. search, workflow, assets)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment muss dev, stage oder prod sein."
  }
}

# Lambda Handlers
variable "handlers" {
  description = "Lambda Handler Definitionen"
  type = list(object({
    name                  = string
    handler               = string
    source_path           = string
    memory_size           = optional(number, 256)
    timeout               = optional(number, 30)
    environment_variables = optional(map(string), {})
    layers                = optional(list(string), [])
  }))
  default = []
}

variable "runtime" {
  description = "Lambda Runtime für alle Handler"
  type        = string
  default     = "python3.13"
}

# DynamoDB Tables
variable "tables" {
  description = "DynamoDB Tabellen Definitionen"
  type = list(object({
    name      = string
    hash_key  = string
    range_key = optional(string)
    attributes = list(object({
      name = string
      type = string
    }))
    global_secondary_indexes = optional(list(object({
      name               = string
      hash_key           = string
      range_key          = optional(string)
      projection_type    = optional(string, "ALL")
      non_key_attributes = optional(list(string))
    })), [])
    stream_enabled = optional(bool, false)
    ttl_attribute  = optional(string)
  }))
  default = []
}

# SQS Queues
variable "queues" {
  description = "SQS Queue Definitionen"
  type = list(object({
    name                       = string
    fifo                       = optional(bool, false)
    visibility_timeout_seconds = optional(number, 30)
    dlq_max_receive_count      = optional(number, 3)
  }))
  default = []
}

# EventBridge Rules
variable "event_rules" {
  description = "EventBridge Rule Definitionen"
  type = list(object({
    name           = string
    event_pattern  = optional(string)
    schedule       = optional(string)
    target_handler = string # Name des Handlers aus var.handlers
  }))
  default = []
}

# VPC Konfiguration (für OpenSearch Zugriff)
variable "vpc_config" {
  description = "VPC-Konfiguration für alle Lambdas (optional)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# IAM Policies
variable "additional_iam_policies" {
  description = "Zusätzliche IAM Policy ARNs für alle Lambda-Rollen"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
