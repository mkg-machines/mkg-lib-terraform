# S3 Module

Erstellt einen S3-Bucket mit Encryption, Public Access Block und optionaler Versionierung.

## Security (erzwungen)

- **Server-Side Encryption**: SSE-S3 (AES-256) mit Bucket Key
- **Public Access Block**: Alle 4 Optionen aktiviert
- **HTTPS-Only**: Bucket Policy erzwingt sichere Übertragung
- **CORS Wildcard Validation**: `*` als Origin nicht erlaubt
- **force_destroy**: Nur in DEV erlaubt

## Verwendung

### Einfacher Bucket

```hcl
module "s3" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/s3?ref=v1.0.0"

  bucket_name = "mkg-prod-assets"
  environment = "prod"
}
```

### Mit Lifecycle Rules

```hcl
module "s3" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/s3?ref=v1.0.0"

  bucket_name = "mkg-prod-assets"
  environment = "prod"

  lifecycle_rules = [
    {
      id                                 = "expire-old-versions"
      noncurrent_version_expiration_days = 90
    },
    {
      id              = "archive-temp"
      prefix          = "temp/"
      expiration_days = 7
    }
  ]
}
```

### Mit CORS

```hcl
module "s3" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/s3?ref=v1.0.0"

  bucket_name = "mkg-prod-assets"
  environment = "prod"

  cors_rules = [
    {
      allowed_headers = ["Authorization", "Content-Type"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://app.mkg-machines.com"]  # Keine Wildcards!
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name des S3-Buckets | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, stage, prod) | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Zusätzliche Tags für alle Ressourcen | `map(string)` | `{}` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS-Regeln (ohne Wildcards!) | <pre>list(object({<br/>    allowed_headers = list(string)<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    expose_headers  = optional(list(string), [])<br/>    max_age_seconds = optional(number, 3600)<br/>  }))</pre> | `[]` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Bucket auch mit Objekten löschen (nur für DEV!) | `bool` | `false` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle-Regeln für Objekte | <pre>list(object({<br/>    id      = string<br/>    enabled = optional(bool, true)<br/>    prefix  = optional(string, "")<br/><br/>    expiration_days                             = optional(number)<br/>    noncurrent_version_expiration_days          = optional(number)<br/>    noncurrent_version_transition_days          = optional(number)<br/>    noncurrent_version_transition_storage_class = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Versionierung aktivieren | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN des S3-Buckets |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Domain-Name des S3-Buckets |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID des S3-Buckets |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name des S3-Buckets |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Regional Domain-Name des S3-Buckets |
<!-- END_TF_DOCS -->
