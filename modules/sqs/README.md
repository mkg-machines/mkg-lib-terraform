# SQS Module

Erstellt eine SQS-Queue mit Dead Letter Queue und Encryption.

## Security (erzwungen)

- **SSE-SQS Encryption**: Immer aktiviert (sqs_managed_sse_enabled)
- **Dead Letter Queue**: Immer erstellt mit Redrive Policy

## Verwendung

### Standard Queue

```hcl
module "sqs" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/sqs?ref=v1.0.0"

  queue_name  = "mkg-prod-events"
  environment = "prod"
}
```

### FIFO Queue

```hcl
module "sqs" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/sqs?ref=v1.0.0"

  queue_name  = "mkg-prod-orders"
  environment = "prod"
  fifo_queue  = true

  content_based_deduplication = true
}
```

### Mit angepassten Timeouts

```hcl
module "sqs" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/sqs?ref=v1.0.0"

  queue_name  = "mkg-prod-long-running"
  environment = "prod"

  visibility_timeout_seconds = 900  # 15 Minuten
  message_retention_seconds  = 1209600  # 14 Tage
  dlq_max_receive_count      = 5
}
```

## Performance-Features

- **Long Polling**: 20s Wait Time als Default (reduziert API-Calls)
- **DLQ Retention**: 14 Tage (länger als Hauptqueue)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_redrive_allow_policy.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name der SQS-Queue | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Content-based Deduplication (nur FIFO) | `bool` | `false` | no |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | Delay für neue Nachrichten in Sekunden | `number` | `0` | no |
| <a name="input_dlq_max_receive_count"></a> [dlq\_max\_receive\_count](#input\_dlq\_max\_receive\_count) | Anzahl Empfangsversuche bevor Nachricht in DLQ landet | `number` | `3` | no |
| <a name="input_dlq_message_retention_seconds"></a> [dlq\_message\_retention\_seconds](#input\_dlq\_message\_retention\_seconds) | Message Retention der DLQ in Sekunden | `number` | `1209600` | no |
| <a name="input_fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | FIFO-Queue erstellen | `bool` | `false` | no |
| <a name="input_max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | Maximale Nachrichtengröße in Bytes (max 262144 = 256 KB) | `number` | `262144` | no |
| <a name="input_message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | Message Retention in Sekunden (max 14 Tage = 1209600) | `number` | `345600` | no |
| <a name="input_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | Long Polling Wait Time in Sekunden | `number` | `20` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | Visibility Timeout in Sekunden | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | ARN der Dead Letter Queue |
| <a name="output_dlq_name"></a> [dlq\_name](#output\_dlq\_name) | Name der Dead Letter Queue |
| <a name="output_dlq_url"></a> [dlq\_url](#output\_dlq\_url) | URL der Dead Letter Queue |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | ARN der SQS-Queue |
| <a name="output_queue_id"></a> [queue\_id](#output\_queue\_id) | ID der SQS-Queue |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | Name der SQS-Queue |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | URL der SQS-Queue |
<!-- END_TF_DOCS -->
