locals {
  # Log Retention nach Environment (MKG Security Standards)
  log_retention_days = {
    dev   = 7
    stage = 30
    prod  = 90
  }

  # Pflicht-Tags (CLAUDE.md)
  default_tags = {
    Project     = "mkg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "mkg-lib-terraform/lambda"
  }

  tags = merge(local.default_tags, var.additional_tags)
}

# IAM Role für Lambda
resource "aws_iam_role" "this" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Basis-Policy für CloudWatch Logs
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC-Policy (falls VPC-Konfiguration vorhanden)
resource "aws_iam_role_policy_attachment" "vpc_execution" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# X-Ray Policy (X-Ray ist erzwungen)
resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Zusätzliche IAM Policies
resource "aws_iam_role_policy_attachment" "additional" {
  count      = length(var.additional_iam_policies)
  role       = aws_iam_role.this.name
  policy_arn = var.additional_iam_policies[count.index]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.function_name}"

  # Log Retention nach Environment (erzwungen)
  retention_in_days = local.log_retention_days[var.environment]

  # KMS Encryption (empfohlen für PROD)
  kms_key_id = var.log_kms_key_arn

  tags = local.tags
}

# Source Code als ZIP
data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

# Lambda-Funktion
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  memory_size = var.memory_size
  timeout     = var.timeout

  # CPU-Architektur (arm64 = Graviton, bessere Kosten/Performance)
  architectures = [var.architecture]

  # Ephemeral Storage (für temporäre Dateien)
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  # X-Ray Tracing (ERZWUNGEN - MKG Security Standards)
  tracing_config {
    mode = "Active"
  }

  # SnapStart für Java Runtimes (reduziert Cold Starts)
  dynamic "snap_start" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  # Reservierte Concurrent Executions
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Umgebungsvariablen
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # VPC-Konfiguration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Lambda Layers
  layers = var.layers

  tags = local.tags

  # Version wird bei SnapStart oder Provisioned Concurrency benötigt
  publish = var.snap_start_enabled || var.provisioned_concurrent_executions > 0

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.basic_execution
  ]
}

# Provisioned Concurrency (für reduzierte Cold Starts)
resource "aws_lambda_provisioned_concurrency_config" "this" {
  count = var.provisioned_concurrent_executions > 0 ? 1 : 0

  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = aws_lambda_function.this.version
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}
