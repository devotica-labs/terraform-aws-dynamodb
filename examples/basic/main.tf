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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/dynamodb/aws"
#   version = "~> 0.1"

module "dynamodb" {
  source = "../.."

  # Table name composes to: dvtca-sandbox-sessions
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "sessions"

  # A simple hash-key-only table keyed on a string id.
  hash_key = "id"
  dynamodb_attributes = [
    { name = "id", type = "S" },
  ]

  # Fintech defaults cover the rest: PAY_PER_REQUEST billing, server-side
  # encryption (aws/dynamodb key), point-in-time recovery on, and deletion
  # protection on.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-dynamodb"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-dynamodb"
  }
}
