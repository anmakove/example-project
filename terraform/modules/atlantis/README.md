## About
This module is inteneded to spin up [Atlantis server](https://www.runatlantis.io) that is being used to operate wit our IaaC.
Atlantis works inside ECS cluster with custom autoscaling rules. Here the current schedule (Kyiv timezone):
```
21:00 - scale to 0
00:00 - scale to 0
startup - manually
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.66 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.66 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_atlantis"></a> [atlantis](#module\_atlantis) | terraform-aws-modules/atlantis/aws | 3.28.0 |
| <a name="module_atlantis_access_log_bucket"></a> [atlantis\_access\_log\_bucket](#module\_atlantis\_access\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_scheduled_action.atlantis_switch_off_daily_evening](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.atlantis_switch_off_daily_midnight](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.atlantis_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.atlantis_access_log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.sso_administrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [github_ip_ranges.actual](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_atlantis_image"></a> [atlantis\_image](#input\_atlantis\_image) | Image name with atlantis | `string` | n/a | yes |
| <a name="input_atlantis_repo_allowlist"></a> [atlantis\_repo\_allowlist](#input\_atlantis\_repo\_allowlist) | Github repositories that should be monitored by Atlantis | `list(string)` | n/a | yes |
| <a name="input_bootstrap_github_app"></a> [bootstrap\_github\_app](#input\_bootstrap\_github\_app) | Flag to configure Atlantis to bootstrap a new Github App | `bool` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | certificate arn | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Route53 domain name to use for ACM certificate. Route53 zone for this domain should be created in advance | `string` | n/a | yes |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | GitHub App ID that is running the Atlantis command | `string` | n/a | yes |
| <a name="input_github_app_key"></a> [github\_app\_key](#input\_github\_app\_key) | The PEM encoded private key for the GitHub App | `string` | n/a | yes |
| <a name="input_github_webhook_secret"></a> [github\_webhook\_secret](#input\_github\_webhook\_secret) | Webhook secret | `string` | n/a | yes |
| <a name="input_iam_admin_role_name"></a> [iam\_admin\_role\_name](#input\_iam\_admin\_role\_name) | IAM Admin role name in an account | `string` | n/a | yes |
| <a name="input_iam_infra_ci_cd_role_name"></a> [iam\_infra\_ci\_cd\_role\_name](#input\_iam\_infra\_ci\_cd\_role\_name) | IAM role name for infrastructure CI/CD in an account | `string` | n/a | yes |
| <a name="input_iam_sso_admin_role_name_prefix"></a> [iam\_sso\_admin\_role\_name\_prefix](#input\_iam\_sso\_admin\_role\_name\_prefix) | IAM Admin role ARN in an account created by AWS SSO | `string` | `"AWSReservedSSO_AdministratorAccess"` | no |
| <a name="input_master_account_id"></a> [master\_account\_id](#input\_master\_account\_id) | AWS root account ID | `string` | n/a | yes |
| <a name="input_oidc_client_id"></a> [oidc\_client\_id](#input\_oidc\_client\_id) | Client ID used in OIDC SSO flow | `string` | n/a | yes |
| <a name="input_oidc_client_secret"></a> [oidc\_client\_secret](#input\_oidc\_client\_secret) | Client Secret used in OIDC SSO flow | `string` | n/a | yes |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | ARNs of atlantis ecs task additional policies | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnets | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atlantis_github_app_setup_url"></a> [atlantis\_github\_app\_setup\_url](#output\_atlantis\_github\_app\_setup\_url) | URL to create a new Github App with Atlantis |
| <a name="output_atlantis_repo_allowlist"></a> [atlantis\_repo\_allowlist](#output\_atlantis\_repo\_allowlist) | Git repositories where webhook should be created |
| <a name="output_atlantis_url"></a> [atlantis\_url](#output\_atlantis\_url) | URL of Atlantis |
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | Task definition for ECS service (used for external triggers) |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | The Atlantis ECS task role arn |
<!-- END_TF_DOCS -->
