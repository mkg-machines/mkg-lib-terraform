variable "api_name" {
  description = "Name der HTTP API"
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

variable "description" {
  description = "Beschreibung der API"
  type        = string
  default     = ""
}

variable "protocol_type" {
  description = "Protokoll-Typ (HTTP oder WEBSOCKET)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "Protocol Type muss HTTP oder WEBSOCKET sein."
  }
}

# JWT Authorizer (MKG Security Standards: erforderlich)
variable "jwt_authorizer" {
  description = "JWT Authorizer Konfiguration (Cognito oder andere OIDC Provider)"
  type = object({
    name             = string
    issuer           = string
    audience         = list(string)
    identity_sources = optional(list(string), ["$request.header.Authorization"])
  })
}

# CORS (MKG Security Standards: keine Wildcards!)
variable "cors_configuration" {
  description = "CORS Konfiguration (keine Wildcards erlaubt!)"
  type = object({
    allow_origins     = list(string)
    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    allow_headers     = optional(list(string), ["Authorization", "Content-Type"])
    expose_headers    = optional(list(string), [])
    allow_credentials = optional(bool, true)
    max_age           = optional(number, 86400)
  })

  validation {
    condition     = !contains(var.cors_configuration.allow_origins, "*")
    error_message = "CORS Wildcard (*) ist nicht erlaubt (MKG Security Standards)."
  }
}

variable "routes" {
  description = "API Routes mit Lambda-Integration"
  type = list(object({
    method             = string
    path               = string
    lambda_arn         = string
    authorization_type = optional(string, "JWT")
  }))
  default = []
}

variable "stage_name" {
  description = "Name der Stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Automatisches Deployment bei Änderungen"
  type        = bool
  default     = true
}

variable "throttling_burst_limit" {
  description = "Throttling Burst Limit"
  type        = number
  default     = 1000
}

variable "throttling_rate_limit" {
  description = "Throttling Rate Limit (requests/second)"
  type        = number
  default     = 500
}

variable "access_log_enabled" {
  description = "Access Logging aktivieren"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
