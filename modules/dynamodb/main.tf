locals {
  # Pflicht-Tags (CLAUDE.md)
  default_tags = {
    Project     = "mkg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "mkg-lib-terraform/dynamodb"
  }

  tags = merge(local.default_tags, var.additional_tags)
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode

  # Table Class (STANDARD_INFREQUENT_ACCESS für selten genutzte Daten = 60% günstiger)
  table_class = var.table_class

  # Provisioned Capacity (nur bei PROVISIONED)
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Keys
  hash_key  = var.hash_key
  range_key = var.range_key

  # Deletion Protection (in PROD erzwungen, sonst konfigurierbar)
  deletion_protection_enabled = coalesce(var.deletion_protection_enabled, var.environment == "prod")

  # Attribute
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Server-Side Encryption (ERZWUNGEN - MKG Security Standards)
  # Mit KMS Key für customer-managed encryption, sonst AWS-managed
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  # Point-in-Time Recovery (ERZWUNGEN - MKG Security Standards)
  point_in_time_recovery {
    enabled = true
  }

  # DynamoDB Streams
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type

      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null

      # PAY_PER_REQUEST: keine Capacity-Angabe
      read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
      write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type

      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [var.ttl_attribute] : []
    content {
      enabled        = true
      attribute_name = ttl.value
    }
  }

  tags = local.tags
}
