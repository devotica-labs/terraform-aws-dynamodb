output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = try(aws_dynamodb_table.this[0].arn, null)
}

output "table_name" {
  description = "Name of the DynamoDB table."
  value       = try(aws_dynamodb_table.this[0].name, null)
}

output "table_id" {
  description = "ID of the DynamoDB table (equal to its name)."
  value       = try(aws_dynamodb_table.this[0].id, null)
}

output "stream_arn" {
  description = "ARN of the table's stream (null when stream_enabled = false)."
  value       = try(aws_dynamodb_table.this[0].stream_arn, null)
}
