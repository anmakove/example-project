# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
# This level is not used for running terragrunt
skip = true

terragrunt_version_constraint = ">= 0.45.0"

locals {
  extra_atlantis_dependencies = [
    find_in_parent_folders("env.hcl"),
    find_in_parent_folders("common.hcl")
  ]

  # Automatically load common Terragrunt inputs
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Automatically load env-level Terragrunt inputs
  env_specific_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_prefix = local.common_vars.inputs.account_prefix # platform
  account_id     = local.env_specific_vars.inputs.account_id
  account_name   = "${local.account_prefix}-${local.env}" # platform-prod
  region         = local.common_vars.inputs.region

  env       = element(split("/", path_relative_to_include()), 1) # dev
  tg_module = basename(path_relative_to_include())               # misc
  state_path = format("%s/%s/%s/%s",
    local.env,
    local.region,
    local.account_prefix,
    local.tg_module
  )

  common_tags = {
    Env           = local.env
    Account       = title(local.account_prefix)
    Orchestration = "Managed by Terraform"
    Team          = "Infrastructure"
    GitRepo       = "repositoryname"
    TgModule      = local.tg_module
  }
}

inputs = merge(
  local.common_vars.inputs,
  local.env_specific_vars.inputs,
  {
    account_name = local.account_name
    env          = local.env
  }
)

remote_state {
  backend = "s3"

  generate = {
    path      = "generated_backend.tf"
    if_exists = "overwrite"
  }

  config = {
    #bucket         = "tf-state-all"
    bucket         = "surprise-tf-state"
    key            = "${local.state_path}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "surprise-tf-locks"
    role_arn       = "arn:aws:iam::098765432109:role/platform-services-prod-admin-shared-terraform"

    disable_bucket_update = true
  }
}

terraform {
  # Force Terraform to keep trying to acquire a lock for up to 15 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = ["-lock-timeout=15m"]
  }
  # Enable tflint execution
  before_hook "before_hook" {
    commands = ["plan"]
    execute  = ["tflint"]
  }
}

generate "providers" {
  path      = "generated_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region              = "${local.region}"
  allowed_account_ids = ["${local.account_id}"]
  default_tags {
    tags = {
%{for k, v in local.common_tags~}
      ${k} = "${v}"
%{endfor~}
    }
  }
}
provider "aws" {
  alias = "platform-secretsmanager"

  region = "${local.region}"
  assume_role {
    role_arn = "arn:aws:iam::098765432109:role/platform-services-prod-admin-shared-terraform"
  }
}
EOF
}

iam_role = "arn:aws:iam::${local.account_id}:role/${local.account_prefix}-services-${local.env}-admin-infra-ci-cd"
