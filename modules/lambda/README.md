# Lambda Module

Erstellt eine AWS Lambda-Funktion mit IAM-Rolle, CloudWatch Log Group und X-Ray Tracing.

## Security (erzwungen)

- **X-Ray Tracing**: Immer aktiviert (`mode = "Active"`)
- **Log Retention**: DEV 7 Tage, STAGE 30 Tage, PROD 90 Tage

## Performance-Features

- **Architektur**: arm64 (Graviton) als Default = 20% besseres Preis/Leistungsverhältnis
- **Provisioned Concurrency**: Optional für eliminierte Cold Starts
- **SnapStart**: Optional für Java Runtimes
- **Ephemeral Storage**: Bis 10GB konfigurierbar

## Verwendung

```hcl
module "lambda" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/lambda?ref=v1.0.0"

  function_name = "mkg-prod-search-indexer"
  environment   = "prod"
  handler       = "main.handler"
  runtime       = "python3.13"
  source_path   = "${path.module}/src"

  memory_size = 512
  timeout     = 60

  environment_variables = {
    DYNAMODB_TABLE = "mkg-prod-entities"
  }

  additional_iam_policies = [
    aws_iam_policy.dynamodb_access.arn
  ]
}
```

## Mit Provisioned Concurrency (für kritische Funktionen)

```hcl
module "lambda" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/lambda?ref=v1.0.0"

  function_name = "mkg-prod-api-handler"
  environment   = "prod"
  handler       = "main.handler"
  runtime       = "python3.13"
  source_path   = "${path.module}/src"

  # Performance: Cold Starts eliminieren
  provisioned_concurrent_executions = 5
}
```

## Mit VPC

```hcl
module "lambda" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/lambda?ref=v1.0.0"

  function_name = "mkg-prod-opensearch-sync"
  environment   = "prod"
  handler       = "main.handler"
  runtime       = "python3.13"
  source_path   = "${path.module}/src"

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
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.xray](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_provisioned_concurrency_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name der Lambda-Funktion (ohne Präfix) | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Handler der Lambda-Funktion (z.B. main.handler) | `string` | n/a | yes |
| <a name="input_source_path"></a> [source\_path](#input\_source\_path) | Pfad zum Source-Code-Verzeichnis | `string` | n/a | yes |
| <a name="input_additional_iam_policies"></a> [additional\_iam\_policies](#input\_additional\_iam\_policies) | Zusätzliche IAM Policy ARNs für die Lambda-Rolle | `list(string)` | `[]` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | CPU-Architektur (arm64 für Graviton = bessere Kosten/Performance, x86\_64 für Kompatibilität) | `string` | `"arm64"` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Umgebungsvariablen für die Lambda-Funktion | `map(string)` | `{}` | no |
| <a name="input_ephemeral_storage_size"></a> [ephemeral\_storage\_size](#input\_ephemeral\_storage\_size) | Ephemeral Storage in MB (512-10240) | `number` | `512` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | Liste von Lambda Layer ARNs | `list(string)` | `[]` | no |
| <a name="input_log_kms_key_arn"></a> [log\_kms\_key\_arn](#input\_log\_kms\_key\_arn) | KMS Key ARN für CloudWatch Log Encryption (empfohlen für PROD) | `string` | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Speicher in MB | `number` | `256` | no |
| <a name="input_provisioned_concurrent_executions"></a> [provisioned\_concurrent\_executions](#input\_provisioned\_concurrent\_executions) | Provisioned Concurrency für reduzierte Cold Starts (kostenpflichtig) | `number` | `0` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Reservierte gleichzeitige Ausführungen (-1 = keine Begrenzung) | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime der Lambda-Funktion | `string` | `"python3.13"` | no |
| <a name="input_snap_start_enabled"></a> [snap\_start\_enabled](#input\_snap\_start\_enabled) | SnapStart aktivieren (nur für Java Runtimes, reduziert Cold Starts) | `bool` | `false` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in Sekunden | `number` | `30` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC-Konfiguration (optional) | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN der Lambda-Funktion |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name der Lambda-Funktion |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN der Lambda-Funktion (für API Gateway) |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN der CloudWatch Log Group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name der CloudWatch Log Group |
| <a name="output_qualified_arn"></a> [qualified\_arn](#output\_qualified\_arn) | Qualified ARN der Lambda-Funktion (mit Version) |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN der IAM-Rolle |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name der IAM-Rolle |
<!-- END_TF_DOCS -->
