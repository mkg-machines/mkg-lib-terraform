# EventBridge Module

Erstellt eine EventBridge Rule mit Targets (Lambda, SQS oder generisch).

## Performance-Features

- **Retry Policy**: Konfigurierbare Wiederholungsversuche (Default: 2)
- **Maximum Event Age**: Konfigurierbar bis 24h (Default: 1h)
- **Dead Letter Queue**: Optional für fehlgeschlagene Events

## Verwendung

### Event Pattern (Event-basiert)

```hcl
module "eventbridge" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/eventbridge?ref=v1.0.0"

  rule_name   = "mkg-prod-entity-created"
  environment = "prod"

  event_pattern = jsonencode({
    source      = ["mkg.kernel"]
    detail-type = ["entity.created"]
  })

  lambda_targets = [
    {
      id           = "search-indexer"
      function_arn = module.lambda.function_arn
    }
  ]
}
```

### Schedule (Zeit-basiert)

```hcl
module "eventbridge" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/eventbridge?ref=v1.0.0"

  rule_name   = "mkg-prod-cleanup"
  environment = "prod"

  schedule_expression = "rate(1 day)"

  lambda_targets = [
    {
      id           = "cleanup-handler"
      function_arn = module.cleanup_lambda.function_arn
    }
  ]
}
```

### Mit Input Transformation

```hcl
module "eventbridge" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/eventbridge?ref=v1.0.0"

  rule_name   = "mkg-prod-entity-events"
  environment = "prod"

  event_pattern = jsonencode({
    source = ["mkg.kernel"]
  })

  targets = [
    {
      id  = "transformer"
      arn = module.lambda.function_arn
      input_transformer = {
        input_paths = {
          entityId = "$.detail.entityId"
          action   = "$.detail-type"
        }
        input_template = <<EOF
{
  "entityId": <entityId>,
  "action": <action>
}
EOF
      }
    }
  ]
}
```

### Mit Retry Policy und DLQ

```hcl
module "eventbridge" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/eventbridge?ref=v1.0.0"

  rule_name   = "mkg-prod-critical-events"
  environment = "prod"

  event_pattern = jsonencode({
    source = ["mkg.kernel"]
  })

  lambda_targets = [
    {
      id                = "critical-handler"
      function_arn      = module.lambda.function_arn
      retry_attempts    = 3
      maximum_event_age = 7200  # 2 Stunden
      dead_letter_arn   = aws_sqs_queue.dlq.arn
    }
  ]
}
```

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
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.generic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_permission.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | Name der EventBridge Rule | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Beschreibung der Rule | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Rule aktiviert | `bool` | `true` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | Name des Event Bus (default = default) | `string` | `"default"` | no |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | Event Pattern als JSON-String | `string` | `null` | no |
| <a name="input_lambda_targets"></a> [lambda\_targets](#input\_lambda\_targets) | Liste der Lambda-Targets (mit automatischer Permission) | <pre>list(object({<br/>    id                = string<br/>    function_arn      = string<br/>    input             = optional(string)<br/>    retry_attempts    = optional(number, 2)<br/>    maximum_event_age = optional(number, 3600) # Max Age in Sekunden (1h default, max 24h)<br/>    dead_letter_arn   = optional(string)       # SQS ARN für fehlgeschlagene Events<br/>  }))</pre> | `[]` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule Expression (z.B. rate(5 minutes) oder cron(...)) | `string` | `null` | no |
| <a name="input_sqs_targets"></a> [sqs\_targets](#input\_sqs\_targets) | Liste der SQS-Targets | <pre>list(object({<br/>    id        = string<br/>    queue_arn = string<br/>    input     = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | Liste der Targets | <pre>list(object({<br/>    id         = string<br/>    arn        = string<br/>    input      = optional(string)<br/>    input_path = optional(string)<br/>    input_transformer = optional(object({<br/>      input_paths    = optional(map(string))<br/>      input_template = string<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_arn"></a> [rule\_arn](#output\_rule\_arn) | ARN der EventBridge Rule |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | ID der EventBridge Rule |
| <a name="output_rule_name"></a> [rule\_name](#output\_rule\_name) | Name der EventBridge Rule |
<!-- END_TF_DOCS -->
