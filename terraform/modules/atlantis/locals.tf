locals {
  name   = "atlantis"
  region = var.region

  tags = merge(var.tags, {})

  alb_ingress_ipv4_cidr_blocks = ["0.0.0.0/0"]

  github_webhooks_ipv4_cidr_blocks = data.github_ip_ranges.actual.hooks_ipv4
  github_webhooks_ipv6_cidr_blocks = data.github_ip_ranges.actual.hooks_ipv6
}
