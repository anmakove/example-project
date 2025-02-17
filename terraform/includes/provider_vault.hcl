generate "provider_vault" {
  path      = "generated_provider_vault.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# tflint-ignore: all
variable "vault_secrets_mount" {
  description = "Vault mount for secrets"
  type        = string
  default     = "secret"
}
data "aws_secretsmanager_secret" "vault_token" {
  provider = aws.vault-platform-secretsmanager
  name     = "vault-token"
}
data "aws_secretsmanager_secret_version" "vault_token" {
  provider  = aws.vault-platform-secretsmanager
  secret_id = data.aws_secretsmanager_secret.vault_token.id
}
provider "aws" {
  alias = "vault-platform-secretsmanager"

  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::098765432109:role/platform-services-prod-admin-shared-terraform"
  }
}
# tflint-ignore: all
variable "vault_prod_address" {
  description = "Address of Prod Vault instance"
  type        = string
  # default     = "https://vault.svc.example.com"
  default     = "https://vault.svc.surprise.dev"
}
# Points on PROD Vault instance
provider "vault" {
  address = var.vault_prod_address
  token   = data.aws_secretsmanager_secret_version.vault_token.secret_string
}
EOF
}
