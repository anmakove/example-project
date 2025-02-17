resource "vault_kv_secret_v2" "params" {
  for_each = {
    for param in var.service_components.vault.params : param.name => { desc = param.description, val = param.value }
    if var.service_components.vault.enabled
  }
  mount               = var.vault_secrets_mount
  name                = "${local.vault_services_path}/${var.service_name}/${each.key}"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      (each.key) = each.value.val
    }
  )
  custom_metadata {
    data = merge(local.vault_metatada,
      {
        Description = each.value.desc
      }
    )
  }
}
