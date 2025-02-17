locals {
  tags = merge(var.tags, {})

  service_domain_zone_name = var.service_domain_zone_external ? var.domain_zone_name : "${var.account_prefix}.${var.domain_zone_name}"
}
