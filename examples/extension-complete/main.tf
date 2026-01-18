terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Beispiel: Search Extension
module "search_extension" {
  source = "../../modules/extension"

  extension_name = "search"
  environment    = var.environment

  # Lambda Handlers
  handlers = [
    {
      name        = "indexer"
      handler     = "handlers.indexer.handler"
      source_path = "${path.module}/src"
      memory_size = 512
      timeout     = 60
      environment_variables = {
        OPENSEARCH_ENDPOINT = var.opensearch_endpoint
      }
    },
    {
      name        = "search"
      handler     = "handlers.search.handler"
      source_path = "${path.module}/src"
      memory_size = 256
      timeout     = 30
      environment_variables = {
        OPENSEARCH_ENDPOINT = var.opensearch_endpoint
      }
    }
  ]

  # DynamoDB Tables
  tables = [
    {
      name      = "index-metadata"
      hash_key  = "PK"
      range_key = "SK"
      attributes = [
        { name = "PK", type = "S" },
        { name = "SK", type = "S" },
        { name = "GSI1PK", type = "S" },
        { name = "GSI1SK", type = "S" }
      ]
      global_secondary_indexes = [
        {
          name            = "GSI1"
          hash_key        = "GSI1PK"
          range_key       = "GSI1SK"
          projection_type = "ALL"
        }
      ]
    }
  ]

  # SQS Queues
  queues = [
    {
      name                       = "reindex-jobs"
      visibility_timeout_seconds = 900
      dlq_max_receive_count      = 3
    }
  ]

  # EventBridge Rules
  event_rules = [
    {
      name = "entity-created"
      event_pattern = jsonencode({
        source      = ["mkg.kernel"]
        detail-type = ["entity.created"]
      })
      target_handler = "indexer"
    },
    {
      name = "entity-updated"
      event_pattern = jsonencode({
        source      = ["mkg.kernel"]
        detail-type = ["entity.updated"]
      })
      target_handler = "indexer"
    },
    {
      name = "entity-deleted"
      event_pattern = jsonencode({
        source      = ["mkg.kernel"]
        detail-type = ["entity.deleted"]
      })
      target_handler = "indexer"
    }
  ]

  # VPC für OpenSearch-Zugriff (optional)
  vpc_config = var.vpc_config
}
