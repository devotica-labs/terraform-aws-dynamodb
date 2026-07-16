# ---------------------------------------------------------------------------
# Keys & attributes
# ---------------------------------------------------------------------------
variable "hash_key" {
  type        = string
  description = "Partition (hash) key attribute name. Required. Must also appear in `attributes`."

  validation {
    condition     = length(var.hash_key) > 0
    error_message = "hash_key must be a non-empty attribute name."
  }
}

variable "range_key" {
  type        = string
  description = "Sort (range) key attribute name. Null (default) creates a hash-key-only table. When set, it must also appear in `dynamodb_attributes`."
  default     = null
}

# Named `dynamodb_attributes` (not `attributes`) because `attributes` is already
# taken by the label-naming surface in label.tf.
variable "dynamodb_attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "DynamoDB key-schema attribute definitions. Must include at least the `hash_key` (and `range_key` when set) plus any attribute projected into a global secondary index. `type` is `S` (string), `N` (number), or `B` (binary)."

  validation {
    condition     = length(var.dynamodb_attributes) >= 1
    error_message = "dynamodb_attributes must define at least the hash_key attribute."
  }

  validation {
    condition     = alltrue([for a in var.dynamodb_attributes : contains(["S", "N", "B"], a.type)])
    error_message = "each attribute type must be one of: S, N, B."
  }

  validation {
    condition     = contains([for a in var.dynamodb_attributes : a.name], var.hash_key)
    error_message = "dynamodb_attributes must include a definition for hash_key."
  }
}

# ---------------------------------------------------------------------------
# Capacity / billing
# ---------------------------------------------------------------------------
variable "billing_mode" {
  type        = string
  description = "PAY_PER_REQUEST (on-demand, the fintech default — no capacity planning, scales to zero cost when idle) or PROVISIONED. PROVISIONED requires `read_capacity` / `write_capacity`."
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "read_capacity" {
  type        = number
  description = "Provisioned read capacity units. Used only when billing_mode = PROVISIONED (ignored for PAY_PER_REQUEST)."
  default     = null
}

variable "write_capacity" {
  type        = number
  description = "Provisioned write capacity units. Used only when billing_mode = PROVISIONED (ignored for PAY_PER_REQUEST)."
  default     = null
}

variable "table_class" {
  type        = string
  description = "Storage class: STANDARD or STANDARD_INFREQUENT_ACCESS."
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# ---------------------------------------------------------------------------
# Global secondary indexes
# ---------------------------------------------------------------------------
variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  description = "Global secondary indexes. `projection_type` is ALL, KEYS_ONLY, or INCLUDE (with `non_key_attributes`). Every GSI key must have a matching definition in `attributes`. `read_capacity`/`write_capacity` apply only under PROVISIONED billing."
  default     = []

  validation {
    condition     = alltrue([for g in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], g.projection_type)])
    error_message = "each global secondary index projection_type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }
}

# ---------------------------------------------------------------------------
# TTL
# ---------------------------------------------------------------------------
variable "ttl" {
  type = object({
    attribute_name = string
    enabled        = bool
  })
  description = "Time-to-live configuration. Disabled by default. When `enabled = true`, DynamoDB expires items whose `attribute_name` epoch timestamp has passed."
  default = {
    attribute_name = ""
    enabled        = false
  }

  validation {
    condition     = !var.ttl.enabled || length(var.ttl.attribute_name) > 0
    error_message = "ttl.attribute_name must be set when ttl.enabled is true."
  }
}

# ---------------------------------------------------------------------------
# Streams
# ---------------------------------------------------------------------------
variable "stream_enabled" {
  type        = bool
  description = "Enable a DynamoDB stream of item-level changes (consumed by Lambda triggers, replication, or change-data-capture)."
  default     = false
}

variable "stream_view_type" {
  type        = string
  description = "What is written to the stream for each change when `stream_enabled = true`: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

# ---------------------------------------------------------------------------
# Encryption (fintech default: on)
# ---------------------------------------------------------------------------
variable "server_side_encryption_enabled" {
  type        = bool
  description = "Enable server-side encryption. Fintech default is true. When enabled with `kms_key_arn = null`, DynamoDB uses the AWS-managed `aws/dynamodb` KMS key; supply `kms_key_arn` for a customer-managed key."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN for server-side encryption. Null (default) uses the AWS-managed `aws/dynamodb` key."
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS ARN (arn:aws*:kms:...) or null."
  }
}

# ---------------------------------------------------------------------------
# Durability & protection (fintech defaults: on)
# ---------------------------------------------------------------------------
variable "point_in_time_recovery_enabled" {
  type        = bool
  description = "Enable point-in-time recovery (continuous backups, restore to any second in the last 35 days). Fintech default is true."
  default     = true
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Block table deletion until explicitly disabled. Fintech default is true so a table can't be destroyed by accident."
  default     = true
}
