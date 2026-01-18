variable "queue_name" {
  description = "Name der SQS-Queue"
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

variable "fifo_queue" {
  description = "FIFO-Queue erstellen"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Content-based Deduplication (nur FIFO)"
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Visibility Timeout in Sekunden"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message Retention in Sekunden (max 14 Tage = 1209600)"
  type        = number
  default     = 345600 # 4 Tage
}

variable "max_message_size" {
  description = "Maximale Nachrichtengröße in Bytes (max 262144 = 256 KB)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delay für neue Nachrichten in Sekunden"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long Polling Wait Time in Sekunden"
  type        = number
  default     = 20
}

variable "dlq_max_receive_count" {
  description = "Anzahl Empfangsversuche bevor Nachricht in DLQ landet"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "Message Retention der DLQ in Sekunden"
  type        = number
  default     = 1209600 # 14 Tage
}

variable "additional_tags" {
  description = "Zusätzliche Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}
