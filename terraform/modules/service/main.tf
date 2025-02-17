resource "kubernetes_namespace" "this" {
  count = var.service_components.namespace.enabled ? 1 : 0
  metadata {
    name   = var.service_name
    labels = merge(local.default_ns_labels, lookup(local.custom_ns_labels, var.service_name, {}))
  }
}

resource "kubernetes_role" "developer" {
  count = var.service_components.namespace.enabled ? 1 : 0

  metadata {
    name      = "developer"
    namespace = kubernetes_namespace.this[0].metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec", "pods/portforward"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["servicemonitors"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["patch", "update"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "patch", "update", "delete"]
  }

  dynamic "rule" {
    for_each = var.env == "prod" ? [] : [1]
    content {
      api_groups = ["apps"]
      resources  = ["deployments", "deployments/rollback", "deployments/scale", "replicasets", "replicasets/scale"]
      verbs      = ["create", "patch", "update"]
    }
  }

  dynamic "rule" {
    for_each = var.env == "prod" ? [] : [1]

    content {
      api_groups = ["autoscaling"]
      resources  = ["horizontalpodautoscalers"]
      verbs      = ["create", "patch", "update"]
    }
  }
}

resource "kubernetes_role_binding" "developer" {
  count = var.service_components.namespace.enabled ? 1 : 0
  metadata {
    name      = "developer"
    namespace = kubernetes_namespace.this[0].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "developer"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "developer"
  }
}
