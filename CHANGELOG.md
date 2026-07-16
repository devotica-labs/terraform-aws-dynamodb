# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([1979b8c](https://github.com/devotica-labs/terraform-aws-dynamodb/commit/1979b8c3588b43e435e058e5b1a6b5e7fb1574bf))
* initial release of terraform-aws-dynamodb ([e745d4e](https://github.com/devotica-labs/terraform-aws-dynamodb/commit/e745d4eaa3136323a3e12bf766778ebbd335173c))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([8db1398](https://github.com/devotica-labs/terraform-aws-dynamodb/commit/8db1398693a6c840c7b458fc3e0c7fcea11b3d29))

## [Unreleased]

### Added

- Initial release: a single Amazon DynamoDB table with fintech-safe defaults —
  PAY_PER_REQUEST billing, server-side encryption (AWS-managed key or a CMK via
  `kms_key_arn`), point-in-time recovery, and deletion protection all on by
  default. Supports composite keys, global secondary indexes, TTL expiry, and
  change streams. Native `label.tf` naming; derived from `cloudposse/terraform-aws-dynamodb`.
