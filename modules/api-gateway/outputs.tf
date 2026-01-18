output "api_id" {
  description = "ID der HTTP API"
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "ARN der HTTP API"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Endpoint der HTTP API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "Execution ARN für Lambda Permissions"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_id" {
  description = "ID der Stage"
  value       = aws_apigatewayv2_stage.this.id
}

output "stage_invoke_url" {
  description = "Invoke URL der Stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "authorizer_id" {
  description = "ID des JWT Authorizers"
  value       = aws_apigatewayv2_authorizer.jwt.id
}

output "log_group_name" {
  description = "Name der CloudWatch Log Group (falls aktiviert)"
  value       = var.access_log_enabled ? aws_cloudwatch_log_group.access_logs[0].name : null
}
