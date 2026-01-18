variable "table_name" {
  description = "Name der DynamoDB-Tabelle"
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

variable "hash_key" {
  description = "Name des Hash Keys (Partition Key)"
  type        = string
}

variable "range_key" {
  description = "Name des Range Keys (Sort Key, optional)"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Liste der Attribute für Keys und Indizes"
  type = list(object({
    name = string
    type = string # S, N, B
  }))
}

variable "billing_mode" {
  description = "Billing Mode (PAY_PER_REQUEST oder PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Billing Mode muss PAY_PER_REQUEST oder PROVISIONED sein."
  }
}

variable "table_class" {
  description = "Table Class (STANDARD für häufigen Zugriff, STANDARD_INFREQUENT_ACCESS für selten genutzte Daten = 60% günstiger)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table Class muss STANDARD oder STANDARD_INFREQUENT_ACCESS sein."
  }
}

variable "read_capacity" {
  description = "Provisioned Read Capacity Units (nur bei PROVISIONED)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Provisioned Write Capacity Units (nur bei PROVISIONED)"
  type        = number
  default     = null
}

variable "global_secondary_indexes" {
  description = "Global Secondary Indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Local Secondary Indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "stream_enabled" {
  description = "DynamoDB Streams aktivieren"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream View Type (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "ttl_attribute" {
  description = "Name des TTL-Attributs (optional)"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS Key ARN für Server-Side Encryption (empfohlen für PROD)"
  type        = string
  default     = null
}

variable "deletion_protection_enabled" {
  description = "Deletion Protection (in PROD automatisch aktiviert)"
  type        = bool
  default     = null
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
