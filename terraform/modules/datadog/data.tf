data "vault_kv_secret_v2" "datadog" {
  mount = "devops-space"
  name  = "${var.env}/datadog"
}

data "aws_regions" "all" {
  all_regions = true
}
