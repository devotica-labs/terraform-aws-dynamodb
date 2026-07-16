# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: a single Amazon DynamoDB table with fintech-safe defaults —
  PAY_PER_REQUEST billing, server-side encryption (AWS-managed key or a CMK via
  `kms_key_arn`), point-in-time recovery, and deletion protection all on by
  default. Supports composite keys, global secondary indexes, TTL expiry, and
  change streams. Native `label.tf` naming; derived from `cloudposse/terraform-aws-dynamodb`.
