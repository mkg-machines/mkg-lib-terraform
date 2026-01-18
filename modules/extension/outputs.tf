# Lambda Outputs
output "lambda_functions" {
  description = "Map aller Lambda-Funktionen"
  value = {
    for name, lambda in module.lambda : name => {
      arn        = lambda.function_arn
      name       = lambda.function_name
      invoke_arn = lambda.invoke_arn
      role_arn   = lambda.role_arn
      role_name  = lambda.role_name
    }
  }
}

output "lambda_arns" {
  description = "Map von Handler-Namen zu Lambda ARNs"
  value       = { for name, lambda in module.lambda : name => lambda.function_arn }
}

output "lambda_invoke_arns" {
  description = "Map von Handler-Namen zu Lambda Invoke ARNs"
  value       = { for name, lambda in module.lambda : name => lambda.invoke_arn }
}

# DynamoDB Outputs
output "dynamodb_tables" {
  description = "Map aller DynamoDB-Tabellen"
  value = {
    for name, table in module.dynamodb : name => {
      arn        = table.table_arn
      name       = table.table_name
      stream_arn = table.stream_arn
    }
  }
}

output "dynamodb_arns" {
  description = "Map von Table-Namen zu ARNs"
  value       = { for name, table in module.dynamodb : name => table.table_arn }
}

# SQS Outputs
output "sqs_queues" {
  description = "Map aller SQS-Queues"
  value = {
    for name, queue in module.sqs : name => {
      arn     = queue.queue_arn
      url     = queue.queue_url
      name    = queue.queue_name
      dlq_arn = queue.dlq_arn
      dlq_url = queue.dlq_url
    }
  }
}

output "sqs_arns" {
  description = "Map von Queue-Namen zu ARNs"
  value       = { for name, queue in module.sqs : name => queue.queue_arn }
}

output "sqs_urls" {
  description = "Map von Queue-Namen zu URLs"
  value       = { for name, queue in module.sqs : name => queue.queue_url }
}

# EventBridge Outputs
output "eventbridge_rules" {
  description = "Map aller EventBridge Rules"
  value = {
    for name, rule in module.eventbridge : name => {
      arn  = rule.rule_arn
      name = rule.rule_name
    }
  }
}

# Extension Info
output "extension_name" {
  description = "Name der Extension"
  value       = var.extension_name
}

output "name_prefix" {
  description = "Prefix für alle Ressourcen"
  value       = local.name_prefix
}
