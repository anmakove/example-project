output "rds" {
  description = "Platform Amazon RDS instance information and DB credentials"
  sensitive   = true
  value = {
    cluster_arn                  = module.platform_db.cluster_arn
    cluster_endpoint             = module.platform_db.cluster_endpoint
    cluster_port                 = module.platform_db.cluster_port
    cluster_database_name        = module.platform_db.cluster_database_name
    cluster_id                   = module.platform_db.cluster_id
    cluster_instances            = module.platform_db.cluster_instances
    cluster_master_username      = module.platform_db.cluster_master_username
    cluster_master_password      = module.platform_db.cluster_master_password
    cluster_members              = module.platform_db.cluster_members
    cluster_reader_endpoint      = module.platform_db.cluster_reader_endpoint
    additional_cluster_endpoints = module.platform_db.additional_cluster_endpoints
    cluster_role_associations    = module.platform_db.cluster_role_associations
    security_group_id            = module.platform_db.security_group_id
  }
}
