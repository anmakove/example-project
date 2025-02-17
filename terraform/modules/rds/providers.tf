provider "postgresql" {
  host            = module.platform_db.cluster_endpoint
  port            = module.platform_db.cluster_port
  database        = "postgres"
  username        = module.platform_db.cluster_master_username
  password        = module.platform_db.cluster_master_password
  sslmode         = "require"
  connect_timeout = 15
  scheme          = "awspostgres"
  superuser       = false
}
