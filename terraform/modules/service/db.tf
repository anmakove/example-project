#####
# PostgreSQL resources
#####
module "postgresql" {
  count  = var.service_components.db.enabled ? 1 : 0
  source = "git::git@github.com:example-org/terraform-module-postgresql.git?ref=v1.8.0"

  providers = {
    postgresql = postgresql.int
  }
  database_create          = true
  datadog_enabled          = var.service_components.db.datadog_enabled
  custom_database_name     = local.db_name
  custom_service_username  = local.db_username
  custom_schema_to_create  = var.service_components.db.custom_schema_to_create
  pg_users_to_create       = var.service_components.db.pg_users_to_create
  pg_tables_to_publish     = var.service_components.db.pg_tables_to_publish
  pg_extensions_to_install = var.service_components.db.pg_extensions_to_install
}

resource "vault_kv_secret_v2" "db_details" {
  count               = var.service_components.db.enabled ? 1 : 0
  mount               = var.vault_secrets_mount
  name                = "${local.vault_services_path}/${var.service_name}/${local.db_details_name}"
  cas                 = 1
  delete_all_versions = false
  data_json           = local.db_details

  custom_metadata {
    data = local.vault_metatada
  }
}
