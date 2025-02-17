variable "region" {
  description = "AWS region ID"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "account_name" {
  description = "AWS project account name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets map with info"
  type        = map(map(string))
}

variable "eks_application_workers_asg_desired_capacity" {
  type        = map(number)
  description = "ASG desired size for system EKS workers per AZ"

  default = {
    "usw2-az1" = 0
    "usw2-az2" = 0
    "usw2-az3" = 0
  }
}
variable "eks_application_workers_asg_min_size" {
  type        = map(number)
  description = "ASG minimum size for system EKS workers per AZ"

  default = {
    "usw2-az1" = 0
    "usw2-az2" = 0
    "usw2-az3" = 0
  }
}

variable "tags" {
  description = "List of tags to all resources"
  default     = {}
  type        = map(string)
}

variable "eks_cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.25"
}

variable "eks_addons" {
  description = "Addon versions to use with EKS cluster"
  type = object({
    vpc_cni = object({
      version = string
    })
    kube_proxy = object({
      version = string
    })
    coredns = object({
      version = string
    })
  })
}

variable "eks_cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_sys_workers_asg_config" {
  description = "ASG parameters for system EKS workers"
  type = object({
    kubelet_label        = string
    asg_desired_capacity = number
    asg_max_size         = number
    asg_min_size         = number
    instance_type        = string
    root_volume_size     = string
    root_volume_type     = string
  })

  default = {
    kubelet_label        = "system"
    asg_desired_capacity = 1
    asg_max_size         = 3
    asg_min_size         = 1
    instance_type        = "t3.medium"
    root_volume_size     = "30"
    root_volume_type     = "gp2"
  }
}

variable "eks_worker_asg_enabled_metrics_list" {
  description = "A list of metrics to be collected from workers' ASG"
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

variable "eks_application_workers_asg_config" {
  description = "ASG parameters for Application EKS workers"
  type = object({
    kubelet_label        = string
    asg_desired_capacity = number
    asg_max_size         = number
    asg_min_size         = number
    instance_type        = string
    root_volume_size     = string
    root_volume_type     = string
    availability_zone    = string
  })

  default = {
    kubelet_label        = "application"
    asg_desired_capacity = 0
    asg_max_size         = 5
    asg_min_size         = 0
    instance_type        = "t3.large"
    root_volume_size     = "50"
    root_volume_type     = "gp2"
    availability_zone    = "us-west-2c"
  }
}

variable "eks_cluster_log_types" {
  description = "List of EKS cluster log types"
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "eks_cluster_log_retention" {
  description = "Number of days for EKS logs retention"
  type        = number
  default     = 90
}

variable "iam_sso_admin_role_name_prefix" {
  description = "IAM Admin role ARN in an account created by AWS SSO"
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess"
}
variable "iam_sso_secops_role_name_prefix" {
  description = "IAM SecOps role name prefix in an account with read-only permissions created by AWS SSO"
  type        = string
  default     = "AWSReservedSSO_SecOps"
}
variable "iam_infra_ci_cd_role_name" {
  description = "IAM role name for infrastructure CI/CD in an account"
  type        = string
}
variable "iam_admin_role_name" {
  description = "IAM Admin role name in an account"
  type        = string
}

variable "aws_auth_additional_roles_map" {
  description = "Map of Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolename = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "jenkins_agents_ns" {
  description = "Namespace for Jenkins agents (used by fargate profile)"
  type        = string
  default     = "jenkins-agents"
}
