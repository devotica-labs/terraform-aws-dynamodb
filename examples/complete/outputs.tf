output "table_name" {
  description = "Name of the table."
  value       = module.dynamodb.table_name
}

output "table_arn" {
  description = "ARN of the table."
  value       = module.dynamodb.table_arn
}

output "table_id" {
  description = "ID of the table."
  value       = module.dynamodb.table_id
}

output "stream_arn" {
  description = "ARN of the table's change stream."
  value       = module.dynamodb.stream_arn
}
