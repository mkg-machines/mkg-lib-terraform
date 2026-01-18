# DynamoDB Module

Erstellt eine DynamoDB-Tabelle mit Encryption, Point-in-Time Recovery und optionalen Sekundärindizes.

## Security (erzwungen)

- **Server-Side Encryption**: Immer aktiviert (optional: Customer-managed KMS)
- **Point-in-Time Recovery**: Immer aktiviert (35 Tage Retention)
- **Deletion Protection**: In PROD automatisch aktiviert

## Performance-Features

- **Table Class**: STANDARD (Default) oder STANDARD_INFREQUENT_ACCESS (60% günstiger)
- **Billing Mode**: PAY_PER_REQUEST (Default) oder PROVISIONED

## Verwendung

### Einfache Tabelle

```hcl
module "dynamodb" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/dynamodb?ref=v1.0.0"

  table_name  = "mkg-prod-entities"
  environment = "prod"

  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" }
  ]
}
```

### Mit Table Class für Archiv-Daten

```hcl
module "dynamodb" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/dynamodb?ref=v1.0.0"

  table_name  = "mkg-prod-audit-logs"
  environment = "prod"

  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" }
  ]

  # 60% günstiger für selten genutzte Daten
  table_class = "STANDARD_INFREQUENT_ACCESS"
}
```

### Mit Global Secondary Index

```hcl
module "dynamodb" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/dynamodb?ref=v1.0.0"

  table_name  = "mkg-prod-entities"
  environment = "prod"

  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" },
    { name = "GSI1PK", type = "S" },
    { name = "GSI1SK", type = "S" }
  ]

  global_secondary_indexes = [
    {
      name            = "GSI1"
      hash_key        = "GSI1PK"
      range_key       = "GSI1SK"
      projection_type = "ALL"
    }
  ]
}
```

### Mit DynamoDB Streams

```hcl
module "dynamodb" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/dynamodb?ref=v1.0.0"

  table_name  = "mkg-prod-entities"
  environment = "prod"

  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Liste der Attribute für Keys und Indizes | <pre>list(object({<br/>    name = string<br/>    type = string # S, N, B<br/>  }))</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Name des Hash Keys (Partition Key) | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name der DynamoDB-Tabelle | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing Mode (PAY\_PER\_REQUEST oder PROVISIONED) | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Deletion Protection (in PROD automatisch aktiviert) | `bool` | `null` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Global Secondary Indexes | <pre>list(object({<br/>    name               = string<br/>    hash_key           = string<br/>    range_key          = optional(string)<br/>    projection_type    = optional(string, "ALL")<br/>    non_key_attributes = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS Key ARN für Server-Side Encryption (empfohlen für PROD) | `string` | `null` | no |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Local Secondary Indexes | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = optional(string, "ALL")<br/>    non_key_attributes = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | Name des Range Keys (Sort Key, optional) | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | Provisioned Read Capacity Units (nur bei PROVISIONED) | `number` | `null` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | DynamoDB Streams aktivieren | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | Stream View Type (NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES, KEYS\_ONLY) | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | Table Class (STANDARD für häufigen Zugriff, STANDARD\_INFREQUENT\_ACCESS für selten genutzte Daten = 60% günstiger) | `string` | `"STANDARD"` | no |
| <a name="input_ttl_attribute"></a> [ttl\_attribute](#input\_ttl\_attribute) | Name des TTL-Attributs (optional) | `string` | `null` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | Provisioned Write Capacity Units (nur bei PROVISIONED) | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | ARN des DynamoDB Streams (falls aktiviert) |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | Label des DynamoDB Streams (falls aktiviert) |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | ARN der DynamoDB-Tabelle |
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | ID der DynamoDB-Tabelle |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name der DynamoDB-Tabelle |
<!-- END_TF_DOCS -->
