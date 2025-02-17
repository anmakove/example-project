#####
# AWS IAM
#####
data "aws_iam_policy_document" "eks_assume" {
  count = var.service_components.serviceaccount.enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.service_namespace}:${var.service_name}"]
    }

    principals {
      identifiers = [var.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "sa" {
  count              = var.service_components.serviceaccount.enabled ? 1 : 0
  name               = "eks-${var.eks.cluster_name}-sa-${var.service_name}"
  description        = "EKS ${var.eks.cluster_name} SA role for ${var.service_name}"
  assume_role_policy = data.aws_iam_policy_document.eks_assume[0].json
  tags               = local.tags
}

resource "vault_kv_secret_v2" "extras" {
  count               = var.service_components.serviceaccount.enabled ? 1 : 0
  mount               = var.vault_secrets_mount
  name                = "${local.vault_services_path}/${var.service_name}/extras"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(var.service_components.serviceaccount.jwt_key ?
    {
      "aws-role-arn"    = aws_iam_role.sa[0].arn
      "jwt-signing-key" = random_id.jwt_signing_key[0].b64_url
    } :
    {
      "aws-role-arn" = aws_iam_role.sa[0].arn
    }
  )
  custom_metadata {
    data = local.vault_metatada
  }
}

resource "kubernetes_secret" "jwt_signing_key" {
  count = var.env == "prod" && var.service_components.serviceaccount.jwt_key ? 1 : 0
  metadata {
    name      = "${var.service_name}-jwt-signing-key"
    namespace = local.service_namespace
    labels    = local.service_k8s_labels
  }
  data = {
    secret-key = random_id.jwt_signing_key[0].b64_url
  }
}

resource "random_id" "jwt_signing_key" {
  count       = var.service_components.serviceaccount.jwt_key ? 1 : 0
  byte_length = 32
}
