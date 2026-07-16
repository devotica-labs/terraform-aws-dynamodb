# Contract tests — naming and the encryption / PITR / deletion-protection
# defaults stay stable across versions.

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "contract"
  hash_key  = "id"
  dynamodb_attributes = [
    { name = "id", type = "S" },
  ]
}

run "table_named_from_label" {
  command = plan
  assert {
    condition     = aws_dynamodb_table.this[0].name == "dvtca-test-contract"
    error_message = "Table name must compose namespace-stage-name."
  }
}

run "encryption_pitr_deletion_protection_on" {
  command = plan
  assert {
    condition     = aws_dynamodb_table.this[0].server_side_encryption[0].enabled == true
    error_message = "Server-side encryption must stay on by default."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].point_in_time_recovery[0].enabled == true
    error_message = "Point-in-time recovery must stay on by default."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].deletion_protection_enabled == true
    error_message = "Deletion protection must stay on by default."
  }
}
