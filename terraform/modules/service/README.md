<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.22 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.16 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.22 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 3.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql) | git::git@github.com:example-org/terraform-module-postgresql.git | v1.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_application.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application) | resource |
| [aws_appconfig_configuration_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment) | resource |
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.appconfig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.appconfig_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.appconfig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.appconfig_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.developer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.developer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.jwt_signing_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_id.jwt_signing_key](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/id) | resource |
| [vault_kv_secret_v2.db_details](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.extras](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.params](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [aws_default_tags.tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.appconfig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.appconfig_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.appconfig_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_account_prefix"></a> [account\_prefix](#input\_account\_prefix) | AWS account prefix | `string` | n/a | yes |
| <a name="input_db_details"></a> [db\_details](#input\_db\_details) | DB for service | `any` | n/a | yes |
| <a name="input_eks"></a> [eks](#input\_eks) | EKS cluster information | <pre>object({<br>    cluster_name               = string<br>    cluster_endpoint           = string<br>    oidc_provider_arn          = string<br>    cluster_oidc_issuer_url    = string<br>    certificate_authority_data = string<br>  })</pre> | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region name | `string` | n/a | yes |
| <a name="input_service_components"></a> [service\_components](#input\_service\_components) | Parameters collection to create for service | <pre>object({<br>    namespace = optional(object({<br>      enabled = bool<br>      name    = optional(string, "")<br>    }), { enabled = false, name = "" })<br>    appconfig = optional(object({<br>      enabled                 = bool<br>      profiles                = list(string)<br>      custom                  = optional(bool, false)<br>      custom_appconfig_id     = optional(string, "")<br>      custom_appconfig_env_id = optional(string, "")<br>      extra                   = optional(bool, false)<br>    }), { enabled = false, profiles = [], extra = false })<br>    serviceaccount = optional(object({<br>      enabled = bool<br>      jwt_key = optional(bool, false)<br>    }), { enabled = false, jwt_key = false })<br>    db = optional(object({<br>      enabled     = optional(bool, false)<br>      db_name     = optional(string, "")<br>      db_username = optional(string, "")<br>      custom_schema_to_create = optional(list(object({<br>        schema_name = string<br>      })), [])<br>      pg_users_to_create = optional(list(object({<br>        username = string<br>        role     = list(string)<br>      })), [])<br>      pg_tables_to_publish     = optional(list(string), [])<br>      pg_extensions_to_install = optional(list(string), [])<br>      redash_datasource_create = optional(bool, false)<br>      datadog_enabled          = optional(bool, false)<br>      deps                     = optional(map(string), {})<br>      friend_finder            = optional(map(string), {})<br>    }), { enabled = false })<br>    s3bucket = optional(object({<br>      enabled = bool<br>    }), { enabled = false })<br>    s3external = optional(object({<br>      enabled    = bool<br>      bucket_arn = string<br>      rw         = optional(bool, false)<br>    }), { enabled = false, bucket_arn = "", rw = false })<br>    dynamodb = optional(object({<br>      enabled = bool<br>    }), { enabled = false })<br>    vault = optional(object({<br>      enabled = bool<br>      params = list(object({<br>        name        = string<br>        value       = string<br>        description = string<br>      }))<br>    }), { enabled = false, params = [] })<br>    debezium = optional(object({<br>      enabled          = bool<br>      connector_config = map(string)<br>    }), { enabled = false, connector_config = {} })<br>    cognito = optional(object({<br>      enabled                            = bool<br>      aws_cognito_user_pool_accounts_arn = string<br>    }), { enabled = false, aws_cognito_user_pool_accounts_arn = "" })<br>  })</pre> | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Service name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_details"></a> [db\_details](#output\_db\_details) | Python data-science RDS information and DB credentials |
<!-- END_TF_DOCS -->