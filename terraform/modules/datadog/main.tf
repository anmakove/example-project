resource "helm_release" "datadog" {
  chart      = "datadog"
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "3.32.8"
  namespace  = "datadog"
  timeout    = 900

  create_namespace = true

  values = [yamlencode(local.datadog_helm_values)]
}
