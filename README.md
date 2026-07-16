# terraform-aws-dynamodb

[![CI](https://github.com/devotica-labs/terraform-aws-dynamodb/actions/workflows/ci.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-dynamodb/actions/workflows/ci.yml)
[![Release](https://github.com/devotica-labs/terraform-aws-dynamodb/actions/workflows/release.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-dynamodb/actions/workflows/release.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Part of the **Devotica** Terraform catalog. Follows the cloudposse module standard (README.yaml-driven docs, the `enabled`/`namespace`/`environment`/`stage`/`name`/`attributes`/`tags`/`label_order` label surface, `examples/complete`, Makefile targets) implemented **natively** — no external naming or build-harness dependencies.

## Introduction

Terraform module for a single **Amazon DynamoDB** table — the fully managed, serverless key-value / document store. It ships fintech-safe defaults so a table is encrypted, recoverable, and protected from accidental deletion out of the box.

Defaults are opinionated: **on-demand billing** (`PAY_PER_REQUEST` — no capacity planning), **server-side encryption** (AWS-managed `aws/dynamodb` key, or supply a CMK), **point-in-time recovery**, and **deletion protection**. Global secondary indexes, TTL expiry, and change streams are all supported via focused inputs.

## Usage

```hcl
module "dynamodb" {
  source  = "devotica-labs/dynamodb/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "sessions"     # table → dvtca-prod-sessions

  hash_key = "id"
  dynamodb_attributes = [
    { name = "id", type = "S" },
  ]

  # Fintech defaults cover encryption, PITR, deletion protection, and billing.
  tags = local.tags
}
```

A composite-key table with a global secondary index, TTL, a change stream, and a customer-managed key:

```hcl
module "dynamodb" {
  source  = "devotica-labs/dynamodb/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "ledger"

  hash_key  = "account_id"
  range_key = "event_time"
  dynamodb_attributes = [
    { name = "account_id", type = "S" },
    { name = "event_time", type = "S" },
    { name = "status", type = "S" },
  ]

  global_secondary_indexes = [
    { name = "status-index", hash_key = "status", range_key = "event_time", projection_type = "ALL" },
  ]

  ttl              = { attribute_name = "ttl_epoch", enabled = true }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  kms_key_arn      = module.kms.key_arn
}
```

See [`examples/basic`](examples/basic) and [`examples/complete`](examples/complete).

## Defaults that matter

| Setting | Default | Why |
|---------|---------|-----|
| `billing_mode` | `PAY_PER_REQUEST` | On-demand: no capacity planning, scales to zero cost when idle. |
| `server_side_encryption_enabled` | `true` | At-rest encryption always on; `kms_key_arn = null` uses the AWS-managed `aws/dynamodb` key, or supply a CMK. |
| `point_in_time_recovery_enabled` | `true` | Continuous backups — restore to any second within the last 35 days. |
| `deletion_protection_enabled` | `true` | A table can't be destroyed by accident. |

## How this fits the Devotica catalog

DynamoDB tables created here back the stateful services in the catalog — session stores, event ledgers, idempotency keys. `terraform-aws-vpc` provisions the `dynamodb` gateway endpoint so traffic stays on the AWS network; pass a CMK from `terraform-aws-kms` into `kms_key_arn` for customer-managed encryption.

## Makefile Targets

```
make fmt       # terraform fmt -recursive
make validate  # terraform init -backend=false && terraform validate
make test      # terraform test (unit + contract; integration needs AWS creds)
make readme    # regenerate the terraform-docs block below
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs regenerates this block via `make readme` / CI. Inputs and
     outputs are documented in variables.tf and outputs.tf. -->
<!-- END_TF_DOCS -->

## License

[Apache 2.0](LICENSE) © Devotica
