output "function_arn" {
  description = "ARN der Lambda-Funktion"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name der Lambda-Funktion"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Invoke ARN der Lambda-Funktion (für API Gateway)"
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "Qualified ARN der Lambda-Funktion (mit Version)"
  value       = aws_lambda_function.this.qualified_arn
}

output "role_arn" {
  description = "ARN der IAM-Rolle"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name der IAM-Rolle"
  value       = aws_iam_role.this.name
}

output "log_group_name" {
  description = "Name der CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN der CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.arn
}
