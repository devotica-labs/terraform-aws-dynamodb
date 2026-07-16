# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A composite-key table for an event ledger: partitioned by account, sorted by
# event time, with a global secondary index for status lookups, TTL-based
# expiry of processed events, a change stream, and a customer-managed KMS key.
module "dynamodb" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "ledger"

  # Composite key: hash = account_id, range = event_time.
  hash_key  = "account_id"
  range_key = "event_time"

  dynamodb_attributes = [
    { name = "account_id", type = "S" },
    { name = "event_time", type = "S" },
    { name = "status", type = "S" },
  ]

  # Global secondary index for querying by processing status.
  global_secondary_indexes = [
    {
      name            = "status-index"
      hash_key        = "status"
      range_key       = "event_time"
      projection_type = "ALL"
    },
  ]

  # Expire items once their `ttl_epoch` timestamp has passed.
  ttl = {
    attribute_name = "ttl_epoch"
    enabled        = true
  }

  # Emit a change stream carrying both before/after item images.
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Customer-managed key instead of the AWS-managed aws/dynamodb key.
  server_side_encryption_enabled = true
  kms_key_arn                    = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  # Explicit fintech durability posture (these are also the defaults).
  point_in_time_recovery_enabled = true
  deletion_protection_enabled    = true

  billing_mode = "PAY_PER_REQUEST"

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-dynamodb"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-dynamodb"
  }
}
