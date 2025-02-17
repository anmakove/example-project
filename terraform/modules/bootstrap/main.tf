resource "aws_route53_zone" "service_domain_zone" {
  name          = local.service_domain_zone_name
  comment       = "DNS zone for development services"
  force_destroy = true

  tags = local.tags
}

data "aws_route53_zone" "domain_zone" {
  name = var.domain_zone_name
}

resource "aws_route53_record" "service_domain_ns_record" {
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name    = var.account_prefix
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.service_domain_zone.name_servers
}

/*
 ACM certificate creation for TLS sessions termination
 ACM certificate could be validated with DNS records at another AWS account
 ref - https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
*/
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v3.0"

  domain_name = local.service_domain_zone_name
  zone_id     = aws_route53_zone.service_domain_zone.zone_id

  subject_alternative_names = ["*.${local.service_domain_zone_name}"]

  validate_certificate = true
  wait_for_validation  = false

  tags = local.tags
}

# Policy for Atlantis ECS task
data "aws_iam_policy_document" "assume_platform_prod" {
  statement {
    sid    = "AssumePlatformProd"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::098765432109:role/platform-services-prod-admin-shared-terraform",
      "arn:aws:iam::*:role/*-admin-infra-ci-cd"
    ]
  }

  statement {
    sid    = "AllowECSExec"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"] #nosecuritycheck: needed for ECS exec permissions
  }
}

resource "aws_iam_policy" "assume_platform_prod" {
  name        = "assume-platform-services-${var.env}-admin-shared-terraform"
  description = "ECS task policy for assuming platform-services-${var.env}-admin-shared-terraform"
  policy      = data.aws_iam_policy_document.assume_platform_prod.json

  tags = local.tags
}
