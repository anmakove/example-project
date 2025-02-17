<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 4.65 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.16 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 4.65 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_platform_db"></a> [platform\_db](#module\_platform\_db) | terraform-aws-modules/rds-aurora/aws | ~> 7.3.0 |
| <a name="module_postgresql_platform_db_init"></a> [postgresql\_platform\_db\_init](#module\_postgresql\_platform\_db\_init) | git::git@github.com:surprise-hr/terraform-module-postgresql.git | v1.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.platform](https://registry.terraform.io/providers/hashicorp/aws/4.65/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.platform](https://registry.terraform.io/providers/hashicorp/aws/4.65/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster_parameter_group.platform](https://registry.terraform.io/providers/hashicorp/aws/4.65/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_security_group.platform_db](https://registry.terraform.io/providers/hashicorp/aws/4.65/docs/resources/security_group) | resource |
| [random_password.db_platform_user_password](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS project account name | `string` | n/a | yes |
| <a name="input_db_platform_config"></a> [db\_platform\_config](#input\_db\_platform\_config) | Database configurations for Platform services | <pre>object({<br>    version                 = string<br>    family                  = string<br>    instance_class          = string<br>    port                    = number<br>    database_name           = string<br>    admin_username          = string<br>    maintenance_window      = string<br>    backup_window           = string<br>    backup_retention_period = number<br>    ca_cert_identifier      = string<br>  })</pre> | n/a | yes |
| <a name="input_db_private_subnets"></a> [db\_private\_subnets](#input\_db\_private\_subnets) | DB Private subnets list | `list(string)` | n/a | yes |
| <a name="input_db_vpc_id"></a> [db\_vpc\_id](#input\_db\_vpc\_id) | VPC ID | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_sg_allowed_cidr_blocks"></a> [sg\_allowed\_cidr\_blocks](#input\_sg\_allowed\_cidr\_blocks) | Allowed CIDR blocks for DB SG | `list(string)` | `[]` | no |
| <a name="input_sg_allowed_security_groups"></a> [sg\_allowed\_security\_groups](#input\_sg\_allowed\_security\_groups) | Allowed SGs for DB SG | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds"></a> [rds](#output\_rds) | Platform Amazon RDS instance information and DB credentials |
<!-- END_TF_DOCS -->