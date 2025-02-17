locals {
  # Automatically load env-level Terragrunt inputs
  env_specific_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  vault_dynamic_address = local.env_specific_vars.inputs.vault_hostname
}

generate "provider_vault_dynamic" {
  path      = "generated_provider_vault_dynamic.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# tflint-ignore: all
variable "vault_dynamic_secrets_mount" {
  description = "Vault mount for secrets"
  type        = string
  default     = "secret"
}
# tflint-ignore: all
variable "vault_hostname" {
  description = "Address of the Vault on the current env"
  type        = string
}
data "aws_secretsmanager_secret" "vault_dynamic_token" {
  name = "vault-token"
}
data "aws_secretsmanager_secret_version" "vault_dynamic_token" {
  secret_id = data.aws_secretsmanager_secret.vault_dynamic_token.id
}
provider "vault" {
  alias            = "dynamic"
  address          = "https://${local.vault_dynamic_address}"
  token            = data.aws_secretsmanager_secret_version.vault_dynamic_token.secret_string
  skip_child_token = true
}
EOF
}
