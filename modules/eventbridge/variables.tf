variable "rule_name" {
  description = "Name der EventBridge Rule"
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

variable "event_bus_name" {
  description = "Name des Event Bus (default = default)"
  type        = string
  default     = "default"
}

variable "description" {
  description = "Beschreibung der Rule"
  type        = string
  default     = ""
}

variable "event_pattern" {
  description = "Event Pattern als JSON-String"
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "Schedule Expression (z.B. rate(5 minutes) oder cron(...))"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Rule aktiviert"
  type        = bool
  default     = true
}

variable "targets" {
  description = "Liste der Targets"
  type = list(object({
    id         = string
    arn        = string
    input      = optional(string)
    input_path = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
  }))
  default = []
}

variable "lambda_targets" {
  description = "Liste der Lambda-Targets (mit automatischer Permission)"
  type = list(object({
    id                = string
    function_arn      = string
    input             = optional(string)
    retry_attempts    = optional(number, 2)
    maximum_event_age = optional(number, 3600) # Max Age in Sekunden (1h default, max 24h)
    dead_letter_arn   = optional(string)       # SQS ARN für fehlgeschlagene Events
  }))
  default = []
}

variable "sqs_targets" {
  description = "Liste der SQS-Targets"
  type = list(object({
    id        = string
    queue_arn = string
    input     = optional(string)
  }))
  default = []
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
