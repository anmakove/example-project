# DEV env will be managed by another tool
locals {
  atlantis_skip = true
}

skip = false

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include("root")}/modules//vpc"
}

inputs = {
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  vpc_cidr               = "172.18.0.0/18"
  db_vpc_cidr            = "10.20.2.0/23"
}
