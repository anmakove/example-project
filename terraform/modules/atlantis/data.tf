################################################################################
# Supporting Resources
################################################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_elb_service_account" "current" {}

data "aws_partition" "current" {}

data "github_ip_ranges" "actual" {}
