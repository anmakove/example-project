<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.18.0 |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | terraform-aws-modules/eks/aws//modules/fargate-profile | ~> 19.15 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_instance_profile.eks_application_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.eks_sys_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.eks_assume_core_schema_registry_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks_application_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_aws_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_sys_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_application_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_assume_core_schema_registry_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_aws_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_sys_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.eks_application_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.eks_sys_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_assume_core_schema_registry_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_aws_node_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.sso_administrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.sso_secops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS project account name | `string` | n/a | yes |
| <a name="input_aws_auth_additional_roles_map"></a> [aws\_auth\_additional\_roles\_map](#input\_aws\_auth\_additional\_roles\_map) | Map of Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolename = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | Addon versions to use with EKS cluster | <pre>object({<br>    vpc_cni = object({<br>      version = string<br>    })<br>    kube_proxy = object({<br>      version = string<br>    })<br>    coredns = object({<br>      version = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_eks_application_workers_asg_config"></a> [eks\_application\_workers\_asg\_config](#input\_eks\_application\_workers\_asg\_config) | ASG parameters for Application EKS workers | <pre>object({<br>    kubelet_label        = string<br>    asg_desired_capacity = number<br>    asg_max_size         = number<br>    asg_min_size         = number<br>    instance_type        = string<br>    root_volume_size     = string<br>    root_volume_type     = string<br>    availability_zone    = string<br>  })</pre> | <pre>{<br>  "asg_desired_capacity": 0,<br>  "asg_max_size": 5,<br>  "asg_min_size": 0,<br>  "availability_zone": "us-west-2c",<br>  "instance_type": "t3.large",<br>  "kubelet_label": "application",<br>  "root_volume_size": "50",<br>  "root_volume_type": "gp2"<br>}</pre> | no |
| <a name="input_eks_application_workers_asg_desired_capacity"></a> [eks\_application\_workers\_asg\_desired\_capacity](#input\_eks\_application\_workers\_asg\_desired\_capacity) | ASG desired size for system EKS workers per AZ | `map(number)` | <pre>{<br>  "usw2-az1": 0,<br>  "usw2-az2": 0,<br>  "usw2-az3": 0<br>}</pre> | no |
| <a name="input_eks_application_workers_asg_min_size"></a> [eks\_application\_workers\_asg\_min\_size](#input\_eks\_application\_workers\_asg\_min\_size) | ASG minimum size for system EKS workers per AZ | `map(number)` | <pre>{<br>  "usw2-az1": 0,<br>  "usw2-az2": 0,<br>  "usw2-az3": 0<br>}</pre> | no |
| <a name="input_eks_cluster_endpoint_public_access_cidrs"></a> [eks\_cluster\_endpoint\_public\_access\_cidrs](#input\_eks\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_eks_cluster_log_retention"></a> [eks\_cluster\_log\_retention](#input\_eks\_cluster\_log\_retention) | Number of days for EKS logs retention | `number` | `90` | no |
| <a name="input_eks_cluster_log_types"></a> [eks\_cluster\_log\_types](#input\_eks\_cluster\_log\_types) | List of EKS cluster log types | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Kubernetes version to use for the EKS cluster | `string` | `"1.25"` | no |
| <a name="input_eks_sys_workers_asg_config"></a> [eks\_sys\_workers\_asg\_config](#input\_eks\_sys\_workers\_asg\_config) | ASG parameters for system EKS workers | <pre>object({<br>    kubelet_label        = string<br>    asg_desired_capacity = number<br>    asg_max_size         = number<br>    asg_min_size         = number<br>    instance_type        = string<br>    root_volume_size     = string<br>    root_volume_type     = string<br>  })</pre> | <pre>{<br>  "asg_desired_capacity": 1,<br>  "asg_max_size": 3,<br>  "asg_min_size": 1,<br>  "instance_type": "t3.medium",<br>  "kubelet_label": "system",<br>  "root_volume_size": "30",<br>  "root_volume_type": "gp2"<br>}</pre> | no |
| <a name="input_eks_worker_asg_enabled_metrics_list"></a> [eks\_worker\_asg\_enabled\_metrics\_list](#input\_eks\_worker\_asg\_enabled\_metrics\_list) | A list of metrics to be collected from workers' ASG | `list(string)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_iam_admin_role_name"></a> [iam\_admin\_role\_name](#input\_iam\_admin\_role\_name) | IAM Admin role name in an account | `string` | n/a | yes |
| <a name="input_iam_infra_ci_cd_role_name"></a> [iam\_infra\_ci\_cd\_role\_name](#input\_iam\_infra\_ci\_cd\_role\_name) | IAM role name for infrastructure CI/CD in an account | `string` | n/a | yes |
| <a name="input_iam_sso_admin_role_name_prefix"></a> [iam\_sso\_admin\_role\_name\_prefix](#input\_iam\_sso\_admin\_role\_name\_prefix) | IAM Admin role ARN in an account created by AWS SSO | `string` | `"AWSReservedSSO_AdministratorAccess"` | no |
| <a name="input_iam_sso_secops_role_name_prefix"></a> [iam\_sso\_secops\_role\_name\_prefix](#input\_iam\_sso\_secops\_role\_name\_prefix) | IAM SecOps role name prefix in an account with read-only permissions created by AWS SSO | `string` | `"AWSReservedSSO_SecOps"` | no |
| <a name="input_jenkins_agents_ns"></a> [jenkins\_agents\_ns](#input\_jenkins\_agents\_ns) | Namespace for Jenkins agents (used by fargate profile) | `string` | `"jenkins-agents"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnets map with info | `map(map(string))` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks"></a> [eks](#output\_eks) | Platform EKS cluster information |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | AWS EKS cluster name |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | Map of created Security Groups IDs |
<!-- END_TF_DOCS -->