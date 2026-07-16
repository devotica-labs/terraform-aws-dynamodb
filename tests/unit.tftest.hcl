# Plan-only unit tests — no AWS credentials required. Assert on config-set
# values and resource cardinality only (computed attributes are unknown under
# a mock provider).

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "unit"
  hash_key  = "id"
  dynamodb_attributes = [
    { name = "id", type = "S" },
  ]
}

run "table_planned" {
  command = plan
  assert {
    condition     = length(aws_dynamodb_table.this) == 1
    error_message = "Exactly one DynamoDB table must be planned."
  }
}

run "fintech_defaults" {
  command = plan
  assert {
    condition     = aws_dynamodb_table.this[0].point_in_time_recovery[0].enabled == true
    error_message = "point-in-time recovery must default to enabled."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].deletion_protection_enabled == true
    error_message = "deletion protection must default to enabled."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].server_side_encryption[0].enabled == true
    error_message = "server-side encryption must default to enabled."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].billing_mode == "PAY_PER_REQUEST"
    error_message = "billing_mode must default to PAY_PER_REQUEST."
  }
}

run "no_stream_by_default" {
  command = plan
  assert {
    condition     = aws_dynamodb_table.this[0].stream_enabled == false
    error_message = "streams must be disabled by default."
  }
}

run "gsi_count" {
  command = plan
  variables {
    range_key = "sk"
    dynamodb_attributes = [
      { name = "id", type = "S" },
      { name = "sk", type = "S" },
      { name = "gsi_pk", type = "S" },
    ]
    global_secondary_indexes = [
      {
        name            = "gsi-1"
        hash_key        = "gsi_pk"
        projection_type = "ALL"
      },
    ]
  }
  assert {
    condition     = length(aws_dynamodb_table.this[0].global_secondary_index) == 1
    error_message = "One global secondary index must be planned per entry."
  }
}

run "provisioned_billing_sets_capacity" {
  command = plan
  variables {
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
  }
  assert {
    condition     = aws_dynamodb_table.this[0].read_capacity == 5
    error_message = "read_capacity must be set under PROVISIONED billing."
  }
  assert {
    condition     = aws_dynamodb_table.this[0].write_capacity == 5
    error_message = "write_capacity must be set under PROVISIONED billing."
  }
}
