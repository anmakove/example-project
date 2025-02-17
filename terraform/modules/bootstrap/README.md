<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.66 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.66 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> v3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.assume_platform_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_route53_record.service_domain_ns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.service_domain_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_iam_policy_document.assume_platform_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.domain_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_account_prefix"></a> [account\_prefix](#input\_account\_prefix) | AWS project account prefix | `string` | n/a | yes |
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | Map of name per AWS account ID allowed for access SOPS KMS key | `map(string)` | n/a | yes |
| <a name="input_domain_zone_name"></a> [domain\_zone\_name](#input\_domain\_zone\_name) | Domain zone name for platform services | `string` | `"svc.surprise.dev"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_iam_infra_ci_cd_role_name"></a> [iam\_infra\_ci\_cd\_role\_name](#input\_iam\_infra\_ci\_cd\_role\_name) | IAM role name for infrastructure CI/CD in an account | `string` | n/a | yes |
| <a name="input_iam_infra_ci_cd_role_name_platform_dev"></a> [iam\_infra\_ci\_cd\_role\_name\_platform\_dev](#input\_iam\_infra\_ci\_cd\_role\_name\_platform\_dev) | IAM role name for infrastructure CI/CD in platform DEV account | `string` | `"platform-services-dev-admin-infra-ci-cd"` | no |
| <a name="input_iam_sso_admin_role_name_prefix"></a> [iam\_sso\_admin\_role\_name\_prefix](#input\_iam\_sso\_admin\_role\_name\_prefix) | IAM Admin role ARN in an account created by AWS SSO | `string` | `"AWSReservedSSO_AdministratorAccess"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region ID | `string` | n/a | yes |
| <a name="input_service_domain_zone_external"></a> [service\_domain\_zone\_external](#input\_service\_domain\_zone\_external) | Whether Route53 zone is managed at another AWS account | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atlantis_task_policy_arn"></a> [atlantis\_task\_policy\_arn](#output\_atlantis\_task\_policy\_arn) | The Atlantis ECS task policy arn |
| <a name="output_certs"></a> [certs](#output\_certs) | ARN of certificates |
| <a name="output_service_domain_zone"></a> [service\_domain\_zone](#output\_service\_domain\_zone) | Account domain zone (if present) |
<!-- END_TF_DOCS -->