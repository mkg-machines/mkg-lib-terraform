# mkg-lib-terraform

Wiederverwendbare Terraform-Module für die MKG Platform.

[![CI](https://github.com/mkg-machines/mkg-lib-terraform/actions/workflows/ci.yml/badge.svg)](https://github.com/mkg-machines/mkg-lib-terraform/actions/workflows/ci.yml)
[![Release](https://github.com/mkg-machines/mkg-lib-terraform/actions/workflows/release.yml/badge.svg)](https://github.com/mkg-machines/mkg-lib-terraform/actions/workflows/release.yml)

## Übersicht

Dieses Repository enthält wiederverwendbare Terraform-Module für AWS-Ressourcen der MKG Platform. Die Module werden von anderen Repositories (Kernel, Extensions, Infrastructure) als Git-Source referenziert.

**Wichtig:** Dieses Repository hat keinen `terraform apply` Schritt. Module werden erst beim Deployment der konsumierenden Repositories ausgeführt.

## Module

| Modul | Beschreibung | Dokumentation |
|-------|--------------|---------------|
| [lambda](./modules/lambda) | AWS Lambda mit IAM, CloudWatch Logs, X-Ray | [README](./modules/lambda/README.md) |
| [dynamodb](./modules/dynamodb) | DynamoDB-Tabelle mit KMS Encryption, PITR | [README](./modules/dynamodb/README.md) |
| [s3](./modules/s3) | S3-Bucket mit Encryption, Public Access Block | [README](./modules/s3/README.md) |
| [sqs](./modules/sqs) | SQS Queue mit DLQ, Encryption | [README](./modules/sqs/README.md) |
| [eventbridge](./modules/eventbridge) | EventBridge Rule + Target | [README](./modules/eventbridge/README.md) |
| [api-gateway](./modules/api-gateway) | HTTP API mit JWT Authorizer, CORS | [README](./modules/api-gateway/README.md) |
| [extension](./modules/extension) | Composite-Modul für komplette Extensions | [README](./modules/extension/README.md) |

## Schnellstart

### Einzelnes Modul verwenden

```hcl
module "lambda" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/lambda?ref=v1.0.0"

  function_name = "mkg-prod-search-indexer"
  environment   = "prod"
  handler       = "main.handler"
  runtime       = "python3.13"
  source_path   = "${path.module}/src"
}
```

### Extension-Modul (empfohlen)

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
    }
  ]

  tables = [
    {
      name      = "metadata"
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
    }
  ]
}
```

## Security

Alle Module erzwingen Security-Defaults gemäß [MKG Security Standards](./MKG_SECURITY_STANDARDS.md):

| Modul | Erzwungene Defaults |
|-------|---------------------|
| lambda | X-Ray Tracing (`mode = "Active"`), Log Retention (7/30/90 Tage) |
| dynamodb | KMS Encryption, Point-in-Time Recovery |
| s3 | Public Access Block (alle 4), SSE-S3 Encryption |
| sqs | SSE-SQS Encryption, Dead Letter Queue |
| api-gateway | JWT Authorizer, CORS ohne Wildcards, Access Logging |
| extension | Kombiniert alle Security-Defaults der Sub-Module |

### Verboten

- `Action = "*"` oder `Resource = "*"` in IAM
- CORS Wildcard (`*`) in API Gateway
- Deaktivierte Encryption
- Public S3 Buckets

## Tags

Alle Ressourcen erhalten automatisch die Pflicht-Tags:

```hcl
Project     = "mkg"
Environment = var.environment  # dev, stage, prod
ManagedBy   = "terraform"
Module      = "mkg-lib-terraform/{module-name}"
```

## Anforderungen

| Tool | Version |
|------|---------|
| Terraform | >= 1.6.0 |
| AWS Provider | >= 5.0 |

## Entwicklung

### Setup

```bash
# Pre-commit Hooks installieren
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg

# TFLint installieren (macOS)
brew install tflint

# Checkov installieren
pip install checkov
```

### Lokale Validierung

```bash
# Formatierung prüfen
terraform fmt -check -recursive

# Alle Module validieren
for module in modules/*/; do
  echo "Validating $module"
  cd "$module" && terraform init -backend=false && terraform validate && cd ../..
done

# TFLint ausführen
tflint --recursive

# Checkov Security Scan
checkov -d modules/ --framework terraform

# Pre-commit für alle Dateien
pre-commit run --all-files
```

### Commit-Messages

Dieses Repository verwendet [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Beschreibung | Version-Bump |
|--------|--------------|--------------|
| `feat:` | Neues Feature | MINOR |
| `fix:` | Bugfix | PATCH |
| `feat!:` oder `BREAKING CHANGE:` | Breaking Change | MAJOR |
| `docs:` | Dokumentation | – |
| `chore:` | Wartung | – |

Beispiele:
```bash
git commit -m "feat: add opensearch module"
git commit -m "fix: correct s3 lifecycle rule syntax"
git commit -m "feat!: rename environment variable to env"
```

## CI/CD

### CI Workflow (Pull Requests)

- `terraform fmt -check`
- `terraform validate` (pro Modul)
- `tflint`
- `checkov` (Security Scan)
- `terraform-docs` (README aktuell?)

### Release Workflow (Main Branch)

- `semantic-release` erstellt automatisch:
  - Git Tag (z.B. `v1.2.0`)
  - GitHub Release
  - CHANGELOG.md Update

### Kein Deploy Workflow

Dieses Repository hat keinen Deploy-Workflow. Module werden erst beim `terraform apply` der konsumierenden Repositories ausgeführt.

## Versionierung

Dieses Repository folgt [Semantic Versioning](https://semver.org/):

| Änderung | Version-Bump | Beispiel |
|----------|--------------|----------|
| Neue optionale Variable mit Default | MINOR | `memory_size` hinzufügen |
| Neues Output | MINOR | `function_arn` hinzufügen |
| Bugfix ohne API-Änderung | PATCH | Typo in Tags korrigieren |
| Variable umbenennen/entfernen | **MAJOR** | `env` → `environment` |
| Output entfernen | **MAJOR** | `arn` entfernen |
| Default-Wert verhaltensändernd | **MAJOR** | `timeout: 30` → `timeout: 60` |

### Rückwärtskompatibilität

Module werden von anderen Repos mit fester Version referenziert:

```hcl
source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/lambda?ref=v1.2.0"
```

Breaking Changes brechen deren Builds. Bei Deprecation: Übergangszeit mit `coalesce()` für alte + neue Variable.

## Beispiele

- [extension-complete](./examples/extension-complete) - Vollständige Extension mit Lambda, DynamoDB, SQS, EventBridge

## Projektstruktur

```
mkg-lib-terraform/
├── modules/
│   ├── lambda/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   ├── dynamodb/
│   ├── s3/
│   ├── sqs/
│   ├── eventbridge/
│   ├── api-gateway/
│   └── extension/
├── examples/
│   └── extension-complete/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── .pre-commit-config.yaml
├── .terraform-docs.yml
├── .tflint.hcl
├── CHANGELOG.md
└── README.md
```

## Links

- [MKG Architecture Guide](./MKG_ARCHITECTURE_GUIDE.md)
- [MKG Security Standards](./MKG_SECURITY_STANDARDS.md)
- [MKG Technology Standards](./MKG_TECHNOLOGY_STANDARDS.md)
- [MKG Repository Overview](./MKG_REPOSITORY_OVERVIEW.md)
