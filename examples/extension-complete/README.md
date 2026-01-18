# Extension Complete Example

Vollständiges Beispiel für eine MKG Extension mit dem `extension`-Modul.

## Übersicht

Dieses Beispiel zeigt eine typische **Search Extension** mit:

- 2 Lambda-Handler (indexer, search)
- 1 DynamoDB-Tabelle mit GSI
- 1 SQS-Queue für Batch-Reindexing
- 3 EventBridge-Rules für Entity-Events

## Struktur

```
extension-complete/
├── main.tf           # Extension-Modul Konfiguration
├── variables.tf      # Input-Variablen
├── outputs.tf        # Output-Werte
├── README.md         # Diese Datei
└── src/              # Lambda Source-Code
    └── handlers/
        ├── indexer.py
        └── search.py
```

## Verwendung

```bash
# Initialisieren
terraform init

# Plan erstellen
terraform plan -var="environment=dev"

# Deployment (nur in konsumierenden Repos!)
terraform apply -var="environment=dev"
```

## Erzeugte Ressourcen

| Ressource | Name |
|-----------|------|
| Lambda | `mkg-dev-search-indexer` |
| Lambda | `mkg-dev-search-search` |
| DynamoDB | `mkg-dev-search-index-metadata` |
| SQS | `mkg-dev-search-reindex-jobs` |
| SQS DLQ | `mkg-dev-search-reindex-jobs-dlq` |
| EventBridge | `mkg-dev-search-entity-created` |
| EventBridge | `mkg-dev-search-entity-updated` |
| EventBridge | `mkg-dev-search-entity-deleted` |

## Mit VPC (für OpenSearch)

```hcl
module "search_extension" {
  source = "../../modules/extension"

  extension_name = "search"
  environment    = "prod"

  vpc_config = {
    subnet_ids         = ["subnet-abc123", "subnet-def456"]
    security_group_ids = ["sg-123456"]
  }

  # ... weitere Konfiguration
}
```

## Hinweis

Dieses Beispiel ist nur zur Demonstration. In echten Deployments wird das `extension`-Modul aus dem Git-Repository referenziert:

```hcl
module "search_extension" {
  source = "git::https://github.com/mkg-machines/mkg-lib-terraform.git//modules/extension?ref=v1.0.0"

  # ...
}
```
