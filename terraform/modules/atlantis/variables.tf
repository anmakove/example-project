variable "tags" {
  description = "List of tags to all resources"
  default     = {}
  type        = map(string)
}

variable "region" {
  description = "AWS region ID"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "domain" {
  description = "Route53 domain name to use for ACM certificate. Route53 zone for this domain should be created in advance"
  type        = string
}

variable "atlantis_repo_allowlist" {
  description = "Github repositories that should be monitored by Atlantis"
  type        = list(string)
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID that is running the Atlantis command"
}

variable "github_app_key" {
  description = "The PEM encoded private key for the GitHub App"
  type        = string
}

variable "github_webhook_secret" {
  description = "Webhook secret"
  type        = string
}

variable "bootstrap_github_app" {
  description = "Flag to configure Atlantis to bootstrap a new Github App"
  type        = bool
}

variable "certificate_arn" {
  description = "certificate arn"
  type        = string
}

# For KMS key
variable "iam_admin_role_name" {
  description = "IAM Admin role name in an account"
  type        = string
}

variable "master_account_id" {
  description = "AWS root account ID"
  type        = string
}

variable "iam_infra_ci_cd_role_name" {
  description = "IAM role name for infrastructure CI/CD in an account"
  type        = string
}

variable "policy_arns" {
  description = "ARNs of atlantis ecs task additional policies"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnets"
  type        = list(string)
}

variable "atlantis_image" {
  description = "Image name with atlantis"
  type        = string
}

variable "oidc_client_id" {
  description = "Client ID used in OIDC SSO flow"
  type        = string
}

variable "oidc_client_secret" {
  description = "Client Secret used in OIDC SSO flow"
  type        = string
}
