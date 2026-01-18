output "table_arn" {
  description = "ARN der DynamoDB-Tabelle"
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  description = "Name der DynamoDB-Tabelle"
  value       = aws_dynamodb_table.this.name
}

output "table_id" {
  description = "ID der DynamoDB-Tabelle"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN des DynamoDB Streams (falls aktiviert)"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "Label des DynamoDB Streams (falls aktiviert)"
  value       = aws_dynamodb_table.this.stream_label
}
