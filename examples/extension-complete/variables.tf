variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "opensearch_endpoint" {
  description = "OpenSearch Endpoint URL"
  type        = string
  default     = ""
}

variable "vpc_config" {
  description = "VPC-Konfiguration für Lambda (optional)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}
