# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial release of mkg-lib-terraform
- `lambda` module - AWS Lambda with IAM, CloudWatch Logs, X-Ray tracing
- `dynamodb` module - DynamoDB table with KMS encryption, PITR
- `s3` module - S3 bucket with encryption, public access block
- `sqs` module - SQS queue with DLQ, encryption
- `eventbridge` module - EventBridge rule with Lambda/SQS targets
- `api-gateway` module - HTTP API with JWT authorizer, CORS
- `extension` module - Composite module for complete extension deployments
- CI workflow with fmt, validate, tflint, checkov, terraform-docs
- Release workflow with semantic-release
- Pre-commit hooks configuration
- Example: extension-complete
