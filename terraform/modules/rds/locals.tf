locals {
  name_prefix = var.account_name
  tags        = merge(var.tags, {})
}
