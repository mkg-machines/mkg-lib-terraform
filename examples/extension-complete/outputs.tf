output "lambda_arns" {
  description = "ARNs aller Lambda-Funktionen"
  value       = module.search_extension.lambda_arns
}

output "dynamodb_tables" {
  description = "DynamoDB Tabellen"
  value       = module.search_extension.dynamodb_tables
}

output "sqs_queues" {
  description = "SQS Queues"
  value       = module.search_extension.sqs_queues
}

output "eventbridge_rules" {
  description = "EventBridge Rules"
  value       = module.search_extension.eventbridge_rules
}

output "extension_name" {
  description = "Name der Extension"
  value       = module.search_extension.extension_name
}
