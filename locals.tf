locals {
  # Table name is the composed label id.
  table_name = local.id

  # Provisioned capacity only applies under PROVISIONED billing; on-demand
  # tables must leave these null.
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
}
