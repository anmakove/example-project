variable "tags" {
  description = "List of tags to all resources"
  default     = {}
  type        = map(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region ID"
  type        = string
}

variable "account_prefix" {
  description = "AWS project account prefix"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "service_domain_zone_external" {
  description = "Whether Route53 zone is managed at another AWS account"
  type        = bool
}

variable "domain_zone_name" {
  description = "Domain zone name for platform services"
  type        = string
  default     = "svc.surprise.dev"
}

variable "iam_sso_admin_role_name_prefix" {
  description = "IAM Admin role ARN in an account created by AWS SSO"
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess"
}

variable "iam_infra_ci_cd_role_name_platform_dev" {
  description = "IAM role name for infrastructure CI/CD in platform DEV account"
  type        = string
  default     = "platform-services-dev-admin-infra-ci-cd"
}

variable "iam_infra_ci_cd_role_name" {
  description = "IAM role name for infrastructure CI/CD in an account"
  type        = string
}

variable "aws_accounts" {
  description = "Map of name per AWS account ID allowed for access SOPS KMS key"
  type        = map(string)
}
