data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "atlantis" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.name
  type    = "A"

  alias {
    name                   = module.atlantis.alb_dns_name
    zone_id                = module.atlantis.alb_zone_id
    evaluate_target_health = true
  }
}
