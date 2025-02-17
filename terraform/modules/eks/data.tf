data "aws_iam_roles" "sso_administrator" {
  name_regex  = var.iam_sso_admin_role_name_prefix
  path_prefix = "/aws-reserved/sso.amazonaws.com/${var.region}/"
}

data "aws_iam_roles" "sso_secops" {
  name_regex  = var.iam_sso_secops_role_name_prefix
  path_prefix = "/aws-reserved/sso.amazonaws.com/${var.region}/"
}

data "aws_eks_addon_version" "this" {
  for_each = toset(["vpc-cni", "kube-proxy", "coredns"])

  addon_name         = each.key
  kubernetes_version = var.eks_cluster_version
  most_recent        = false
}
