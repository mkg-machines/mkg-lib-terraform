locals {
  # Pflicht-Tags (CLAUDE.md)
  default_tags = {
    Project     = "mkg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "mkg-lib-terraform/extension"
    Extension   = var.extension_name
  }

  tags = merge(local.default_tags, var.additional_tags)

  # Prefix für alle Ressourcen
  name_prefix = "mkg-${var.environment}-${var.extension_name}"

  # Handler-Map für einfachen Zugriff
  handler_map = { for h in var.handlers : h.name => h }
}

# Lambda Handlers
module "lambda" {
  source   = "../lambda"
  for_each = { for h in var.handlers : h.name => h }

  function_name = "${local.name_prefix}-${each.value.name}"
  environment   = var.environment
  handler       = each.value.handler
  runtime       = var.runtime
  source_path   = each.value.source_path
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout

  environment_variables = merge(
    each.value.environment_variables,
    {
      EXTENSION_NAME = var.extension_name
      ENVIRONMENT    = var.environment
    },
    # DynamoDB Table Names
    { for t in var.tables : "DYNAMODB_TABLE_${upper(replace(t.name, "-", "_"))}" => "${local.name_prefix}-${t.name}" },
    # SQS Queue URLs (werden nach Erstellung gesetzt)
    {}
  )

  vpc_config              = var.vpc_config
  layers                  = each.value.layers
  additional_iam_policies = var.additional_iam_policies
  additional_tags         = local.tags
}

# DynamoDB Tables
module "dynamodb" {
  source   = "../dynamodb"
  for_each = { for t in var.tables : t.name => t }

  table_name  = "${local.name_prefix}-${each.value.name}"
  environment = var.environment
  hash_key    = each.value.hash_key
  range_key   = each.value.range_key
  attributes  = each.value.attributes

  global_secondary_indexes = each.value.global_secondary_indexes
  stream_enabled           = each.value.stream_enabled
  ttl_attribute            = each.value.ttl_attribute

  additional_tags = local.tags
}

# SQS Queues
module "sqs" {
  source   = "../sqs"
  for_each = { for q in var.queues : q.name => q }

  queue_name                 = "${local.name_prefix}-${each.value.name}"
  environment                = var.environment
  fifo_queue                 = each.value.fifo
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  dlq_max_receive_count      = each.value.dlq_max_receive_count

  additional_tags = local.tags
}

# EventBridge Rules
module "eventbridge" {
  source   = "../eventbridge"
  for_each = { for r in var.event_rules : r.name => r }

  rule_name   = "${local.name_prefix}-${each.value.name}"
  environment = var.environment

  event_pattern       = each.value.event_pattern
  schedule_expression = each.value.schedule

  lambda_targets = [
    {
      id           = each.value.target_handler
      function_arn = module.lambda[each.value.target_handler].function_arn
    }
  ]

  additional_tags = local.tags
}

# IAM Policy für DynamoDB-Zugriff
resource "aws_iam_policy" "dynamodb_access" {
  count = length(var.tables) > 0 ? 1 : 0

  name = "${local.name_prefix}-dynamodb-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = concat(
          [for t in var.tables : module.dynamodb[t.name].table_arn],
          [for t in var.tables : "${module.dynamodb[t.name].table_arn}/index/*"]
        )
      }
    ]
  })

  tags = local.tags
}

# IAM Policy für SQS-Zugriff
resource "aws_iam_policy" "sqs_access" {
  count = length(var.queues) > 0 ? 1 : 0

  name = "${local.name_prefix}-sqs-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [for q in var.queues : module.sqs[q.name].queue_arn]
      }
    ]
  })

  tags = local.tags
}

# Attach Policies to Lambda Roles
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  for_each = length(var.tables) > 0 ? { for h in var.handlers : h.name => h } : {}

  role       = module.lambda[each.key].role_name
  policy_arn = aws_iam_policy.dynamodb_access[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  for_each = length(var.queues) > 0 ? { for h in var.handlers : h.name => h } : {}

  role       = module.lambda[each.key].role_name
  policy_arn = aws_iam_policy.sqs_access[0].arn
}
