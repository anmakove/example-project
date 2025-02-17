
locals {
  # secrets = yamldecode(sops_decrypt_file(("${get_terragrunt_dir()}/secrets.yaml")))
  secrets = yamldecode(file("${get_terragrunt_dir()}/secrets.yaml"))
}

include "root" {
  path = find_in_parent_folders()
}

include "provider_vault" {
  path = find_in_parent_folders("includes/provider_vault.hcl")
}


terraform {
  source = "${path_relative_from_include("root")}/modules//service"
}

dependencies {
  paths = ["../rds", "../eks"]
}

dependency "rds" {
  config_path = "../rds"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    rds = {
      cluster_endpoint        = "mock"
      cluster_reader_endpoint = "mock"
      cluster_port            = 5432
      cluster_database_name   = "postgres"
      cluster_master_username = "mock-admin"
      cluster_master_password = "mock-password"
    }
  }
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    eks = {
      cluster_endpoint           = "mock"
      cluster_name               = "mock"
      oidc_provider_arn          = "postgres"
      cluster_oidc_issuer_url    = "mock"
      certificate_authority_data = "bW9jawo="
    }
  }
}

inputs = {
  service_name = "example-service"
  service_components = {
    namespace = {
      enabled = true
    }
    serviceaccount = {
      enabled = true
    }
    appconfig = {
      enabled = true
      profiles = [
        "account"
      ]
    }
    db = {
      enabled = true
      pg_users_to_create = [
        {
          username = "one_shot_jobs_account"
          role     = ["readonly"]
        }
      ]
    }
    vault = {
      enabled = true
      params = [
        {
          name        = "SOME_CUSTOM_SECRET"
          value       = local.secrets.SOME_CUSTOM_SECRET
          description = "Token for some third-party service"
        }
      ]
    }
  }

  eks = {
    cluster_name               = dependency.eks.outputs.eks.cluster_name
    cluster_endpoint           = dependency.eks.outputs.eks.cluster_endpoint
    oidc_provider_arn          = dependency.eks.outputs.eks.oidc_provider_arn
    cluster_oidc_issuer_url    = dependency.eks.outputs.eks.cluster_oidc_issuer_url
    certificate_authority_data = dependency.eks.outputs.eks.certificate_authority_data
  }

  db_details = {
    db_host        = dependency.rds.outputs.rds.cluster_endpoint
    db_reader_host = dependency.rds.outputs.rds.cluster_reader_endpoint
    db_port        = dependency.rds.outputs.rds.cluster_port
    db_name        = dependency.rds.outputs.rds.cluster_database_name
    db_username    = dependency.rds.outputs.rds.cluster_master_username
    db_password    = dependency.rds.outputs.rds.cluster_master_password
  }
}
