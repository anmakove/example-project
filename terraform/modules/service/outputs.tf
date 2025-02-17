output "db_details" {
  description = "Python data-science RDS information and DB credentials"
  sensitive   = true
  value = var.service_components.db.enabled ? {
    db_host     = var.db_details.db_host
    db_port     = var.db_details.db_port
    db_name     = local.db_name
    db_username = module.postgresql[0].user_creds.service_user_username
    db_password = module.postgresql[0].user_creds.service_user_password
    users       = try({ for k, v in module.postgresql[0].user_creds.users : replace(k, "-", "_") => { username = k, password = v } }, {})
    } : {
    db_host     = ""
    db_port     = ""
    db_name     = ""
    db_username = ""
    db_password = ""
    users       = {}
  }
}
