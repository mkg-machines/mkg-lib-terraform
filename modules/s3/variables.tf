variable "bucket_name" {
  description = "Name des S3-Buckets"
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

variable "versioning_enabled" {
  description = "Versionierung aktivieren"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle-Regeln für Objekte"
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    prefix  = optional(string, "")

    expiration_days                             = optional(number)
    noncurrent_version_expiration_days          = optional(number)
    noncurrent_version_transition_days          = optional(number)
    noncurrent_version_transition_storage_class = optional(string)
  }))
  default = []
}

variable "cors_rules" {
  description = "CORS-Regeln (ohne Wildcards!)"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.cors_rules : !contains(rule.allowed_origins, "*")])
    error_message = "CORS Wildcard (*) in allowed_origins ist nicht erlaubt (MKG Security Standards)."
  }
}

variable "force_destroy" {
  description = "Bucket auch mit Objekten löschen (nur für DEV!)"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
