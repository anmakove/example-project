# DEV env will be managed by another tool
locals {
  atlantis_skip = true
}

skip = false

retryable_errors = [
  ".*The vpc ID .* does not exist.*",
  ".*i/o timeout"
]

include "root" {
  path = find_in_parent_folders()
}
include "provider_k8s" {
  path = find_in_parent_folders("includes/provider_k8s_eks.hcl")
}
terraform {
  source = "${path_relative_from_include("root")}/modules//eks"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    vpc = {
      vpc_id         = "mock"
      vpc_cidr_block = "10.0.0.0"
      "private_subnets_info" = {
        "127.0.0.0/22" = {
          "availability_zone"    = "us-west-2a"
          "availability_zone_id" = "usw2-az1"
          "subnet_cidr"          = "127.0.0.0/22"
          "subnet_id"            = "subnet-mock1"
        }
        "127.0.4.0/22" = {
          "availability_zone"    = "us-west-2b"
          "availability_zone_id" = "usw2-az2"
          "subnet_cidr"          = "127.0.0.0/22"
          "subnet_id"            = "subnet-mock2"
        }
        "127.0.8.0/22" = {
          "availability_zone"    = "us-west-2c"
          "availability_zone_id" = "usw2-az3"
          "subnet_cidr"          = "127.0.0.0/22"
          "subnet_id"            = "subnet-mock3"
        }
      }
    }
  }
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc.vpc_id
  private_subnets = dependency.vpc.outputs.vpc.private_subnets_info
  vpc_cidr        = dependency.vpc.outputs.vpc.vpc_cidr_block

  eks_cluster_version = "1.30"
  eks_addons = {
    vpc_cni = {
      version = "v1.18.6-eksbuild.1"
    }
    kube_proxy = {
      version = "v1.30.6-eksbuild.3"
    }
    coredns = {
      version = "v1.11.3-eksbuild.2"
    }
  }
  aws_auth_additional_roles_map = [
    {
      rolename = "eks-platform-dev-app-workers"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  iam_infra_ci_cd_role_name = "platform-admin-ci-cd"
  iam_admin_role_name       = "platform-admin-team"
}
