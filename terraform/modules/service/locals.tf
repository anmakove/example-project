locals {
  service_name      = replace(var.service_name, "-", "_")
  db_name           = var.service_components.db.db_name == "" ? local.service_name : var.service_components.db.db_name
  db_username       = var.service_components.db.db_username == "" ? local.service_name : var.service_components.db.db_username
  bucket_name       = "surprise-${var.service_name}-${var.env}"
  service_namespace = var.service_components.namespace.enabled ? kubernetes_namespace.this[0].metadata[0].name : "data-science"
  default_ns_labels = {
    monitoring                                = "enabled"
    "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
  }
  custom_ns_labels = {
    ("support-admin-panel") = {
      monitoring = "disabled"
    }
  }
  k8s_tags = {
    for k, v in data.aws_default_tags.tags.tags : k => replace(replace(v, "/", "."), " ", "_")
  }
  service_tags = merge(local.k8s_tags, {
    Service = var.service_name
  })
  service_k8s_labels  = merge(local.k8s_tags, local.service_tags)
  vault_metatada      = merge(data.aws_default_tags.tags.tags, local.tags)
  vault_services_path = "services/${var.env}/${var.account_prefix}"

  db_details_ds_int = var.service_components.db.enabled ? {
    "url_int" = "postgres://${local.db_username}:${module.postgresql[0].user_creds.service_user_password}@${var.db_details.db_host}:${var.db_details.db_port}/${local.db_name}"
  } : {}
  db_details_api_int = var.service_components.db.enabled ? {
    full_url              = "postgresql://${var.db_details.db_host}:${var.db_details.db_port}/${local.db_name}"
    replica_full_url      = "postgresql://${var.db_details.db_reader_host}:${var.db_details.db_port}/${local.db_name}"
    service_user_username = module.postgresql[0].user_creds.service_user_username
    service_user_password = module.postgresql[0].user_creds.service_user_password
  } : {}
  db_details_api_vibes = var.service_components.db.enabled && length(var.service_components.db.friend_finder) != 0 ? {
    friend_finder_url         = "postgresql://${var.db_details.db_host}:${var.db_details.db_port}/friend_finder"
    friend_finder_replica_url = "postgresql://${var.db_details.db_reader_host}:${var.db_details.db_port}/friend_finder"
    friend_finder_user_name   = var.service_components.db.friend_finder.username
    friend_finder_password    = var.service_components.db.friend_finder.password
  } : {}
  db_details_ds_deps = length(var.service_components.db.deps) != 0 ? {
    tostring(var.service_components.db.deps.alias) = "postgres://${var.service_components.db.deps.db_username}:${var.service_components.db.deps.db_password}@${var.service_components.db.deps.db_host}:${var.service_components.db.deps.db_port}/${var.service_components.db.deps.db_name}"
  } : {}
  db_details      = var.db_details.db_reader_host == "" ? jsonencode(merge(local.db_details_ds_int, local.db_details_ds_deps)) : jsonencode(merge(local.db_details_api_int, local.db_details_api_vibes))
  db_details_name = var.db_details.db_reader_host == "" ? "db-details" : "db_details"
  tags = {
    Service = var.service_name
  }
}
