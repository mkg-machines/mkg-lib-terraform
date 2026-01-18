locals {
  # Pflicht-Tags (CLAUDE.md)
  default_tags = {
    Project     = "mkg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "mkg-lib-terraform/eventbridge"
  }

  tags = merge(local.default_tags, var.additional_tags)
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "this" {
  name           = var.rule_name
  description    = var.description
  event_bus_name = var.event_bus_name

  # Entweder Event Pattern oder Schedule
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression

  state = var.enabled ? "ENABLED" : "DISABLED"

  tags = local.tags
}

# Generische Targets
resource "aws_cloudwatch_event_target" "generic" {
  for_each = { for t in var.targets : t.id => t }

  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = var.event_bus_name
  target_id      = each.value.id
  arn            = each.value.arn

  input      = each.value.input
  input_path = each.value.input_path

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }
}

# Lambda Targets mit automatischer Permission
resource "aws_cloudwatch_event_target" "lambda" {
  for_each = { for t in var.lambda_targets : t.id => t }

  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = var.event_bus_name
  target_id      = each.value.id
  arn            = each.value.function_arn
  input          = each.value.input

  # Retry Policy (Performance-Optimierung)
  retry_policy {
    maximum_retry_attempts       = each.value.retry_attempts
    maximum_event_age_in_seconds = each.value.maximum_event_age
  }

  # Dead Letter Queue für fehlgeschlagene Events
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_arn != null ? [1] : []
    content {
      arn = each.value.dead_letter_arn
    }
  }
}

resource "aws_lambda_permission" "eventbridge" {
  for_each = { for t in var.lambda_targets : t.id => t }

  statement_id  = "AllowEventBridge-${var.rule_name}-${each.value.id}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

# SQS Targets
resource "aws_cloudwatch_event_target" "sqs" {
  for_each = { for t in var.sqs_targets : t.id => t }

  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = var.event_bus_name
  target_id      = each.value.id
  arn            = each.value.queue_arn
  input          = each.value.input
}
