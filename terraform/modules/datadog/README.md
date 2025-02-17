There was a need to apply an empty state first in order to mitigate the following error:
```terraform
╷
│ Error: Invalid provider configuration
│ 
│   on /Users/val/Surprise/Sources/infra-repos/terraform/configs/core-infra/terraform/environments/prod/datadog/.terragrunt-cache/60T8JZMuN3fynIu7n2XiaAu2OPU/aiQuCEJyr-rQyyElM3oTgnwrPec/datadog/generated_providers.tf line 32:
│   32: provider "vault" {
│ 
│ The configuration for provider["registry.terraform.io/hashicorp/vault"]
│ depends on values that cannot be determined until apply.
╵
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.1 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~> 3.23 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.9.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.1 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | ~> 3.23 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.9.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 3.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [datadog_integration_aws_account.datadog_aws_integration](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account) | resource |
| [helm_release.datadog](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.datadog_aws_integration_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_regions.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |
| [vault_kv_secret_v2.datadog](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS project account name | `string` | n/a | yes |
| <a name="input_available_aws_regions"></a> [available\_aws\_regions](#input\_available\_aws\_regions) | List of AWS regions available for DD integration | `list(string)` | n/a | yes |
| <a name="input_aws_integration_enabled"></a> [aws\_integration\_enabled](#input\_aws\_integration\_enabled) | Whether to enable DatDog AWS integration or not | `bool` | n/a | yes |
| <a name="input_datadog_agent_affinity"></a> [datadog\_agent\_affinity](#input\_datadog\_agent\_affinity) | Affinity configuration for DataDog agent daemonset | `any` | `{}` | no |
| <a name="input_datadog_agent_features"></a> [datadog\_agent\_features](#input\_datadog\_agent\_features) | List of Enabled/Disabled DataDog agent features | <pre>object({<br>    dogstatsd_enabled               = bool<br>    kube_state_metrics_core_enabled = bool<br>    logs_enabled                    = bool<br>    network_monitoring_enabled      = bool<br>    process_agent_enabled           = bool<br>    service_monitoring_enabled      = bool<br>  })</pre> | n/a | yes |
| <a name="input_datadog_api_url"></a> [datadog\_api\_url](#input\_datadog\_api\_url) | DataDog API url | `string` | `"https://api.us5.datadoghq.com/"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name/id of the EKS cluster. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->