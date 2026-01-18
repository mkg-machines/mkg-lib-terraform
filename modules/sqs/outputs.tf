output "queue_arn" {
  description = "ARN der SQS-Queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "URL der SQS-Queue"
  value       = aws_sqs_queue.this.url
}

output "queue_name" {
  description = "Name der SQS-Queue"
  value       = aws_sqs_queue.this.name
}

output "queue_id" {
  description = "ID der SQS-Queue"
  value       = aws_sqs_queue.this.id
}

output "dlq_arn" {
  description = "ARN der Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  description = "URL der Dead Letter Queue"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_name" {
  description = "Name der Dead Letter Queue"
  value       = aws_sqs_queue.dlq.name
}
