output "certs" {
  description = "ARN of certificates"
  value = {
    (local.service_domain_zone_name) = module.acm.acm_certificate_arn
  }
}

output "service_domain_zone" {
  description = "Account domain zone (if present)"
  value = {
    name = aws_route53_zone.service_domain_zone.name
    id   = aws_route53_zone.service_domain_zone.zone_id
  }
}

output "atlantis_task_policy_arn" {
  description = "The Atlantis ECS task policy arn"
  value       = aws_iam_policy.assume_platform_prod.arn
}
