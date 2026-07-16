# A single DynamoDB table with fintech-safe defaults: server-side encryption on
# (AWS-managed KMS key unless a CMK is supplied), point-in-time recovery on,
# deletion protection on, and PAY_PER_REQUEST (on-demand) billing.
resource "aws_dynamodb_table" "this" {
  count = local.enabled ? 1 : 0

  name         = local.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key
  table_class  = var.table_class

  # Null under PAY_PER_REQUEST; the provider rejects capacity on on-demand tables.
  read_capacity  = local.read_capacity
  write_capacity = local.write_capacity

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  deletion_protection_enabled = var.deletion_protection_enabled

  dynamic "attribute" {
    for_each = var.dynamodb_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
      read_capacity      = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  server_side_encryption {
    enabled = var.server_side_encryption_enabled
    # Null selects the AWS-managed aws/dynamodb key; a CMK ARN selects that key.
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  dynamic "ttl" {
    for_each = var.ttl.enabled ? [1] : []
    content {
      attribute_name = var.ttl.attribute_name
      enabled        = true
    }
  }

  tags = local.tags
}
