include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include("root")}/modules//atlantis"
}

dependencies {
  paths = ["../bootstrap"]
}

dependency "bootstrap" {
  config_path = "../bootstrap"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    certs = {
      "dev.example.com" = "mock"
    }
    atlantis_task_policy_arn = "mock"
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    vpc = {
      vpc_id          = "vpc-1234567890"
      private_subnets = ["subnet-00000000", "subnet-111111", "subnet-222222222"]
      public_subnets  = ["subnet-33333333", "subnet-444444", "subnet-555555555"]
    }
  }
}

locals {
  # gh_app  = yamldecode(sops_decrypt_file(("${get_terragrunt_dir()}/gh_app.yaml")))
  # secrets = yamldecode(sops_decrypt_file(("${get_terragrunt_dir()}/secrets.yaml")))
  gh_app  = yamldecode(file("${get_terragrunt_dir()}/gh_app.yaml"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/secrets.yaml"))
}

inputs = {
  domain                  = "dev.example.com"
  github_owner            = "example-org"
  atlantis_repo_allowlist = ["github.com/example-org/*"]

  atlantis_image = "0987654321.dkr.ecr.us-west-2.amazonaws.com/internal/atlantis-terragrunt:1.2.1"

  certificate_arn = dependency.bootstrap.outputs.certs["dev.example.com"]

  #  TODO: Should be set to 'true' during first phase of provisioning
  #        and set to 'false' when there are actual values of gh app
  bootstrap_github_app = true

  github_app_id         = local.gh_app.gh-app-id
  github_app_key        = local.gh_app.app-key
  github_webhook_secret = local.gh_app.gh-webhook-secret

  policy_arns = [dependency.bootstrap.outputs.atlantis_task_policy_arn]
  #  TODO: use dependency
  vpc_id = dependency.vpc.outputs.vpc.vpc_id

  private_subnet_ids = dependency.vpc.outputs.vpc.private_subnets
  public_subnet_ids  = dependency.vpc.outputs.vpc.public_subnets

  oidc_client_id     = local.secrets.google_oidc_client_id
  oidc_client_secret = local.secrets.google_oidc_client_secret
}
