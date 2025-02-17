# DEV env will be managed by another tool
locals {
  atlantis_skip = true
}

skip = false

retryable_errors = [
  "Error connecting to PostgreSQL server .* no such host"
]

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include("root")}/modules//rds"
}

dependencies {
  paths = ["../vpc", "../eks"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    vpc = {
      vpc_id                  = "mock"
      private_route_table_ids = []
      vpc_cidr_block          = "172.18.0.0/18"
      private_subnets = [
        "mock"
      ]
    }
    db_vpc = {
      vpc_id                  = "mock"
      vpc_cidr_block          = "10.20.2.0/23"
      private_route_table_ids = []
      private_subnets = [
        "mock"
      ]
    }
  }
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    security_groups = {
      eks-platform-dev-application-workers = "mock"
    }
  }
}

inputs = {
  db_platform_config = {
    version                 = "14.5"
    family                  = "aurora-postgresql"
    instance_class          = "db.t4g.medium"
    port                    = 5432
    database_name           = "platform"
    admin_username          = "surprise_admin"
    maintenance_window      = "Mon:00:00-Mon:03:00"
    backup_window           = "03:00-06:00"
    backup_retention_period = "15"
    ca_cert_identifier      = "rds-ca-rsa2048-g1"
  }
  sg_allowed_cidr_blocks = [dependency.vpc.outputs.vpc.vpc_cidr_block]
  sg_allowed_security_groups = [
    dependency.eks.outputs.security_groups["eks-platform-dev-application-workers"]
  ]
  db_vpc_id                  = dependency.vpc.outputs.db_vpc.vpc_id
  db_vpc_cidr                = dependency.vpc.outputs.db_vpc.vpc_cidr_block
  db_private_subnets         = dependency.vpc.outputs.db_vpc.private_subnets
  db_private_route_table_ids = dependency.vpc.outputs.db_vpc.private_route_table_ids
}
