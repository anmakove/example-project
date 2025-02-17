# DEV env will be managed by another tool
locals {
  atlantis_skip = true
}

skip = false

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include("root")}/modules//bootstrap"
}

inputs = {
  service_domain_zone_external = false
  domain_zone_name             = "dev.example.com"
}
