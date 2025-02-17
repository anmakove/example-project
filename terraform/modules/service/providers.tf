provider "postgresql" {
  alias = "int"

  host            = var.db_details.db_host
  port            = var.db_details.db_port
  database        = var.db_details.db_name
  username        = var.db_details.db_username
  password        = var.db_details.db_password
  sslmode         = "require"
  connect_timeout = 15
  scheme          = "awspostgres"
  superuser       = false
}

provider "kubernetes" {
  host                   = var.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(var.eks.certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks.cluster_name]
    command     = "aws"
  }
}

provider "aws" {
  alias = "platform-prod"

  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::098765432109:role/platform-services-prod-admin-shared-terraform"
  }
}
