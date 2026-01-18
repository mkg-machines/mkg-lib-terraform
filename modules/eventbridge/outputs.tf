output "rule_arn" {
  description = "ARN der EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.arn
}

output "rule_name" {
  description = "Name der EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.name
}

output "rule_id" {
  description = "ID der EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.id
}
