dependency "providerdep_rds" {
  config_path = "../rds"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    rds = {
      cluster_endpoint        = "mock"
      cluster_port            = 5432
      cluster_master_username = "mock"
      cluster_master_password = "mock"
    }
  }
}
generate "provider_postgres" {
  path      = "generated_provider_postgres.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "postgresql" {
  alias = "platform_db"

  host            = "${dependency.providerdep_rds.outputs.rds.cluster_endpoint}"
  port            = "${dependency.providerdep_rds.outputs.rds.cluster_port}"
  database        = "postgres"
  username        = "${dependency.providerdep_rds.outputs.rds.cluster_master_username}"
  password        = "${dependency.providerdep_rds.outputs.rds.cluster_master_password}"
  sslmode         = "require"
  connect_timeout = 15
  scheme          = "awspostgres"
  superuser       = false
}
EOF
}
