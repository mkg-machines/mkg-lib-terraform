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
    Module      = "mkg-lib-terraform/api-gateway"
  }

  tags = merge(local.default_tags, var.additional_tags)
}

# HTTP API
resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  description   = var.description
  protocol_type = var.protocol_type

  # CORS (MKG Security Standards: keine Wildcards)
  cors_configuration {
    allow_origins     = var.cors_configuration.allow_origins
    allow_methods     = var.cors_configuration.allow_methods
    allow_headers     = var.cors_configuration.allow_headers
    expose_headers    = var.cors_configuration.expose_headers
    allow_credentials = var.cors_configuration.allow_credentials
    max_age           = var.cors_configuration.max_age
  }

  tags = local.tags
}

# JWT Authorizer (MKG Security Standards: erforderlich)
resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  name             = var.jwt_authorizer.name
  identity_sources = var.jwt_authorizer.identity_sources

  jwt_configuration {
    issuer   = var.jwt_authorizer.issuer
    audience = var.jwt_authorizer.audience
  }
}

# Lambda Integrations
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = { for r in var.routes : "${r.method}-${r.path}" => r }

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "this" {
  for_each = { for r in var.routes : "${r.method}-${r.path}" => r }

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${each.value.method} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"

  # Authorization (JWT als Default)
  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorization_type == "JWT" ? aws_apigatewayv2_authorizer.jwt.id : null
}

# Lambda Permissions
resource "aws_lambda_permission" "api_gateway" {
  for_each = { for r in var.routes : "${r.method}-${r.path}" => r }

  statement_id  = "AllowAPIGateway-${replace(each.key, "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# CloudWatch Log Group für Access Logs
resource "aws_cloudwatch_log_group" "access_logs" {
  count = var.access_log_enabled ? 1 : 0

  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = local.log_retention_days[var.environment]

  tags = local.tags
}

# Stage
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  # Throttling
  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }

  # Access Logging
  dynamic "access_log_settings" {
    for_each = var.access_log_enabled ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs[0].arn
      format = jsonencode({
        requestId         = "$context.requestId"
        ip                = "$context.identity.sourceIp"
        requestTime       = "$context.requestTime"
        httpMethod        = "$context.httpMethod"
        routeKey          = "$context.routeKey"
        status            = "$context.status"
        protocol          = "$context.protocol"
        responseLength    = "$context.responseLength"
        integrationError  = "$context.integrationErrorMessage"
        errorMessage      = "$context.error.message"
        authorizerError   = "$context.authorizer.error"
        integrationStatus = "$context.integrationStatus"
      })
    }
  }

  tags = local.tags
}
