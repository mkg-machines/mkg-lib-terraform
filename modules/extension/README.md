# Extension Module

Composite-Modul für vollständige Extension-Deployments. Kombiniert Lambda, DynamoDB, SQS und EventBridge.

## Zweck

Dieses Modul vereinfacht das Deployment von MKG Extensions. Statt jeden Service einzeln zu konfigurieren, werden alle Ressourcen einer Extension zusammen definiert.

## Features

- Lambda-Handler mit automatischem DynamoDB/SQS-Zugriff
- DynamoDB-Tabellen mit erzwungenen Security-Defaults
- SQS-Queues mit automatischer DLQ
- EventBridge-Rules für Event-Handling
- Automatische IAM-Policies
- Konsistentes Naming: `mkg-{env}-{extension}-{resource}`

## Verwendung

### Einfache Extension

```hcl
module "search_extension" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/extension?ref=v1.0.0"

  extension_name = "search"
  environment    = "prod"

  handlers = [
    {
      name        = "indexer"
      handler     = "handlers.indexer.handler"
      source_path = "${path.module}/src"
      memory_size = 512
      timeout     = 60
    },
    {
      name        = "search"
      handler     = "handlers.search.handler"
      source_path = "${path.module}/src"
      memory_size = 256
      timeout     = 30
    }
  ]

  tables = [
    {
      name      = "index-metadata"
      hash_key  = "PK"
      range_key = "SK"
      attributes = [
        { name = "PK", type = "S" },
        { name = "SK", type = "S" }
      ]
    }
  ]

  event_rules = [
    {
      name           = "entity-created"
      event_pattern  = jsonencode({
        source      = ["mkg.kernel"]
        detail-type = ["entity.created"]
      })
      target_handler = "indexer"
    },
    {
      name           = "entity-updated"
      event_pattern  = jsonencode({
        source      = ["mkg.kernel"]
        detail-type = ["entity.updated"]
      })
      target_handler = "indexer"
    }
  ]
}
```

### Mit SQS und VPC

```hcl
module "import_extension" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/extension?ref=v1.0.0"

  extension_name = "import"
  environment    = "prod"

  handlers = [
    {
      name        = "processor"
      handler     = "handlers.processor.handler"
      source_path = "${path.module}/src"
      memory_size = 1024
      timeout     = 900
    }
  ]

  tables = [
    {
      name      = "jobs"
      hash_key  = "PK"
      range_key = "SK"
      attributes = [
        { name = "PK", type = "S" },
        { name = "SK", type = "S" }
      ]
      ttl_attribute = "expires_at"
    }
  ]

  queues = [
    {
      name                       = "import-jobs"
      visibility_timeout_seconds = 900
      dlq_max_receive_count      = 3
    }
  ]

  vpc_config = {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.dynamodb_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sqs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_extension_name"></a> [extension\_name](#input\_extension\_name) | Name der Extension (z.B. search, workflow, assets) | `string` | n/a | yes |
| <a name="input_additional_iam_policies"></a> [additional\_iam\_policies](#input\_additional\_iam\_policies) | Zusätzliche IAM Policy ARNs für alle Lambda-Rollen | `list(string)` | `[]` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_event_rules"></a> [event\_rules](#input\_event\_rules) | EventBridge Rule Definitionen | <pre>list(object({<br/>    name           = string<br/>    event_pattern  = optional(string)<br/>    schedule       = optional(string)<br/>    target_handler = string # Name des Handlers aus var.handlers<br/>  }))</pre> | `[]` | no |
| <a name="input_handlers"></a> [handlers](#input\_handlers) | Lambda Handler Definitionen | <pre>list(object({<br/>    name                  = string<br/>    handler               = string<br/>    source_path           = string<br/>    memory_size           = optional(number, 256)<br/>    timeout               = optional(number, 30)<br/>    environment_variables = optional(map(string), {})<br/>    layers                = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | SQS Queue Definitionen | <pre>list(object({<br/>    name                       = string<br/>    fifo                       = optional(bool, false)<br/>    visibility_timeout_seconds = optional(number, 30)<br/>    dlq_max_receive_count      = optional(number, 3)<br/>  }))</pre> | `[]` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda Runtime für alle Handler | `string` | `"python3.13"` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | DynamoDB Tabellen Definitionen | <pre>list(object({<br/>    name      = string<br/>    hash_key  = string<br/>    range_key = optional(string)<br/>    attributes = list(object({<br/>      name = string<br/>      type = string<br/>    }))<br/>    global_secondary_indexes = optional(list(object({<br/>      name               = string<br/>      hash_key           = string<br/>      range_key          = optional(string)<br/>      projection_type    = optional(string, "ALL")<br/>      non_key_attributes = optional(list(string))<br/>    })), [])<br/>    stream_enabled = optional(bool, false)<br/>    ttl_attribute  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC-Konfiguration für alle Lambdas (optional) | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_arns"></a> [dynamodb\_arns](#output\_dynamodb\_arns) | Map von Table-Namen zu ARNs |
| <a name="output_dynamodb_tables"></a> [dynamodb\_tables](#output\_dynamodb\_tables) | Map aller DynamoDB-Tabellen |
| <a name="output_eventbridge_rules"></a> [eventbridge\_rules](#output\_eventbridge\_rules) | Map aller EventBridge Rules |
| <a name="output_extension_name"></a> [extension\_name](#output\_extension\_name) | Name der Extension |
| <a name="output_lambda_arns"></a> [lambda\_arns](#output\_lambda\_arns) | Map von Handler-Namen zu Lambda ARNs |
| <a name="output_lambda_functions"></a> [lambda\_functions](#output\_lambda\_functions) | Map aller Lambda-Funktionen |
| <a name="output_lambda_invoke_arns"></a> [lambda\_invoke\_arns](#output\_lambda\_invoke\_arns) | Map von Handler-Namen zu Lambda Invoke ARNs |
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | Prefix für alle Ressourcen |
| <a name="output_sqs_arns"></a> [sqs\_arns](#output\_sqs\_arns) | Map von Queue-Namen zu ARNs |
| <a name="output_sqs_queues"></a> [sqs\_queues](#output\_sqs\_queues) | Map aller SQS-Queues |
| <a name="output_sqs_urls"></a> [sqs\_urls](#output\_sqs\_urls) | Map von Queue-Namen zu URLs |
<!-- END_TF_DOCS -->

## Automatisches IAM

Das Modul erstellt automatisch IAM-Policies für:

1. **DynamoDB**: Alle Handler erhalten Zugriff auf alle Tabellen der Extension
2. **SQS**: Alle Handler erhalten Zugriff auf alle Queues der Extension

Für Cross-Extension-Zugriff können zusätzliche Policies über `additional_iam_policies` hinzugefügt werden.

## Naming-Konvention

Alle Ressourcen folgen dem Pattern:
```
mkg-{environment}-{extension_name}-{resource_name}
```

Beispiele für `extension_name = "search"` und `environment = "prod"`:
- Lambda: `mkg-prod-search-indexer`
- DynamoDB: `mkg-prod-search-index-metadata`
- SQS: `mkg-prod-search-import-jobs`
- EventBridge: `mkg-prod-search-entity-created`
