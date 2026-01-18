variable "function_name" {
  description = "Name der Lambda-Funktion (ohne Präfix)"
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

variable "handler" {
  description = "Handler der Lambda-Funktion (z.B. main.handler)"
  type        = string
}

variable "runtime" {
  description = "Runtime der Lambda-Funktion"
  type        = string
  default     = "python3.13"
}

variable "memory_size" {
  description = "Speicher in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Timeout in Sekunden"
  type        = number
  default     = 30
}

variable "source_path" {
  description = "Pfad zum Source-Code-Verzeichnis"
  type        = string
}

variable "environment_variables" {
  description = "Umgebungsvariablen für die Lambda-Funktion"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC-Konfiguration (optional)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "layers" {
  description = "Liste von Lambda Layer ARNs"
  type        = list(string)
  default     = []
}

variable "reserved_concurrent_executions" {
  description = "Reservierte gleichzeitige Ausführungen (-1 = keine Begrenzung)"
  type        = number
  default     = -1
}

variable "provisioned_concurrent_executions" {
  description = "Provisioned Concurrency für reduzierte Cold Starts (kostenpflichtig)"
  type        = number
  default     = 0
}

variable "architecture" {
  description = "CPU-Architektur (arm64 für Graviton = bessere Kosten/Performance, x86_64 für Kompatibilität)"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "Architecture muss arm64 oder x86_64 sein."
  }
}

variable "ephemeral_storage_size" {
  description = "Ephemeral Storage in MB (512-10240)"
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "Ephemeral Storage muss zwischen 512 und 10240 MB liegen."
  }
}

variable "snap_start_enabled" {
  description = "SnapStart aktivieren (nur für Java Runtimes, reduziert Cold Starts)"
  type        = bool
  default     = false
}

variable "additional_iam_policies" {
  description = "Zusätzliche IAM Policy ARNs für die Lambda-Rolle"
  type        = list(string)
  default     = []
}

variable "log_kms_key_arn" {
  description = "KMS Key ARN für CloudWatch Log Encryption (empfohlen für PROD)"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
