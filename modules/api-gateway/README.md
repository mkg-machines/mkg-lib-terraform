# API Gateway Module

Erstellt eine HTTP API mit JWT Authorizer, CORS und Lambda-Integration.

## Security (erzwungen)

- **JWT Authorizer**: Pflicht für alle Endpoints (außer explizit NONE)
- **CORS**: Keine Wildcards erlaubt (Validation Error bei `*`)
- **Access Logging**: Aktiviert mit Log Retention nach Environment

## Verwendung

### Mit Cognito

```hcl
module "api_gateway" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/api-gateway?ref=v1.0.0"

  api_name    = "mkg-prod-api"
  environment = "prod"

  jwt_authorizer = {
    name     = "cognito"
    issuer   = "https://cognito-idp.eu-central-1.amazonaws.com/${aws_cognito_user_pool.this.id}"
    audience = [aws_cognito_user_pool_client.this.id]
  }

  cors_configuration = {
    allow_origins = ["https://app.mkg-machines.com"]
  }

  routes = [
    {
      method     = "GET"
      path       = "/entities"
      lambda_arn = module.list_entities.function_arn
    },
    {
      method     = "POST"
      path       = "/entities"
      lambda_arn = module.create_entity.function_arn
    },
    {
      method     = "GET"
      path       = "/entities/{id}"
      lambda_arn = module.get_entity.function_arn
    },
    {
      method     = "PUT"
      path       = "/entities/{id}"
      lambda_arn = module.update_entity.function_arn
    },
    {
      method     = "DELETE"
      path       = "/entities/{id}"
      lambda_arn = module.delete_entity.function_arn
    }
  ]
}
```

### Health Endpoint ohne Auth

```hcl
module "api_gateway" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/api-gateway?ref=v1.0.0"

  api_name    = "mkg-prod-api"
  environment = "prod"

  jwt_authorizer = {
    name     = "cognito"
    issuer   = "https://cognito-idp.eu-central-1.amazonaws.com/${aws_cognito_user_pool.this.id}"
    audience = [aws_cognito_user_pool_client.this.id]
  }

  cors_configuration = {
    allow_origins = ["https://app.mkg-machines.com"]
  }

  routes = [
    {
      method             = "GET"
      path               = "/health"
      lambda_arn         = module.health.function_arn
      authorization_type = "NONE"
    },
    {
      method     = "GET"
      path       = "/entities"
      lambda_arn = module.list_entities.function_arn
    }
  ]
}
```

## Performance-Features

- **Throttling**: Konfigurierbar (Default: 1000 burst, 500 req/s)
- **Access Logging**: Detailliertes Format für Performance-Analyse

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_authorizer.jwt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer) | resource |
| [aws_apigatewayv2_integration.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | Name der HTTP API | `string` | n/a | yes |
| <a name="input_cors_configuration"></a> [cors\_configuration](#input\_cors\_configuration) | CORS Konfiguration (keine Wildcards erlaubt!) | <pre>object({<br/>    allow_origins     = list(string)<br/>    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])<br/>    allow_headers     = optional(list(string), ["Authorization", "Content-Type"])<br/>    expose_headers    = optional(list(string), [])<br/>    allow_credentials = optional(bool, true)<br/>    max_age           = optional(number, 86400)<br/>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_jwt_authorizer"></a> [jwt\_authorizer](#input\_jwt\_authorizer) | JWT Authorizer Konfiguration (Cognito oder andere OIDC Provider) | <pre>object({<br/>    name             = string<br/>    issuer           = string<br/>    audience         = list(string)<br/>    identity_sources = optional(list(string), ["$request.header.Authorization"])<br/>  })</pre> | n/a | yes |
| <a name="input_access_log_enabled"></a> [access\_log\_enabled](#input\_access\_log\_enabled) | Access Logging aktivieren | `bool` | `true` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_auto_deploy"></a> [auto\_deploy](#input\_auto\_deploy) | Automatisches Deployment bei Änderungen | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Beschreibung der API | `string` | `""` | no |
| <a name="input_protocol_type"></a> [protocol\_type](#input\_protocol\_type) | Protokoll-Typ (HTTP oder WEBSOCKET) | `string` | `"HTTP"` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | API Routes mit Lambda-Integration | <pre>list(object({<br/>    method             = string<br/>    path               = string<br/>    lambda_arn         = string<br/>    authorization_type = optional(string, "JWT")<br/>  }))</pre> | `[]` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name der Stage | `string` | `"$default"` | no |
| <a name="input_throttling_burst_limit"></a> [throttling\_burst\_limit](#input\_throttling\_burst\_limit) | Throttling Burst Limit | `number` | `1000` | no |
| <a name="input_throttling_rate_limit"></a> [throttling\_rate\_limit](#input\_throttling\_rate\_limit) | Throttling Rate Limit (requests/second) | `number` | `500` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_arn"></a> [api\_arn](#output\_api\_arn) | ARN der HTTP API |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | Endpoint der HTTP API |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | ID der HTTP API |
| <a name="output_authorizer_id"></a> [authorizer\_id](#output\_authorizer\_id) | ID des JWT Authorizers |
| <a name="output_execution_arn"></a> [execution\_arn](#output\_execution\_arn) | Execution ARN für Lambda Permissions |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name der CloudWatch Log Group (falls aktiviert) |
| <a name="output_stage_id"></a> [stage\_id](#output\_stage\_id) | ID der Stage |
| <a name="output_stage_invoke_url"></a> [stage\_invoke\_url](#output\_stage\_invoke\_url) | Invoke URL der Stage |
<!-- END_TF_DOCS -->
