# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A single on-demand hash-key table is cheap and fast to create/destroy.
# deletion_protection_enabled is off so teardown is clean.

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace = "dvtca"
  stage     = "integ"
  name      = "ddb"
  hash_key  = "id"
  dynamodb_attributes = [
    { name = "id", type = "S" },
  ]
  deletion_protection_enabled = false

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = aws_dynamodb_table.this[0].arn != ""
    error_message = "Table must be created with an ARN."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].billing_mode == "PAY_PER_REQUEST"
    error_message = "Table must apply as PAY_PER_REQUEST against the real API."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].point_in_time_recovery[0].enabled == true
    error_message = "Point-in-time recovery must apply cleanly."
  }
}
