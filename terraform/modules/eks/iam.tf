data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#####
# EKS System workers
#####
resource "aws_iam_role" "eks_sys_workers" {
  name               = "eks-${local.eks_cluster_name}-system-workers"
  description        = "Role for system workers of ${local.eks_cluster_name} EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.tags
}

resource "aws_iam_instance_profile" "eks_sys_workers" {
  name = "eks-${local.eks_cluster_name}-system-workers"
  role = aws_iam_role.eks_sys_workers.name

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_sys_workers" {
  for_each = local.eks_worker_iam_default_aws_policies

  role       = aws_iam_role.eks_sys_workers.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

#####
# EKS AWS Node DaemonSet
#####
data "aws_iam_policy_document" "eks_aws_node_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_aws_node" {
  name               = "eks-${local.eks_cluster_name}-aws-node"
  description        = "EKS ${local.eks_cluster_name} aws-node role"
  assume_role_policy = data.aws_iam_policy_document.eks_aws_node_assume.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_aws_node" {
  role       = aws_iam_role.eks_aws_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#####
# EKS Application workers
#####
resource "aws_iam_role" "eks_application_workers" {
  name               = "eks-${local.eks_cluster_name}-application-workers"
  description        = "Role for Application workers of ${local.eks_cluster_name} EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.tags
}

resource "aws_iam_instance_profile" "eks_application_workers" {
  name = "eks-${local.eks_cluster_name}-application-workers"
  role = aws_iam_role.eks_application_workers.name

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_application_workers" {
  for_each = local.eks_worker_iam_default_aws_policies

  role       = aws_iam_role.eks_application_workers.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

data "aws_iam_policy_document" "eks_assume_core_schema_registry_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    # DEV env is temporarily decommissioned
    # resources = [for env in ["dev", "qa", "prod"] : data.terraform_remote_state.kafka_schema[env].outputs.kafka_schema_registry.akhq_iam_role_arn]
    resources = [for env in ["qa", "prod"] : data.terraform_remote_state.kafka_schema[env].outputs.kafka_schema_registry.akhq_iam_role_arn]
  }
}

resource "aws_iam_policy" "eks_assume_core_schema_registry_role" {
  name   = "eks-${local.eks_cluster_name}-assume-core-schema-registry-role"
  path   = "/"
  policy = data.aws_iam_policy_document.eks_assume_core_schema_registry_role.json
}

resource "aws_iam_role_policy_attachment" "eks_assume_core_schema_registry_role" {
  role       = aws_iam_role.eks_application_workers.name
  policy_arn = aws_iam_policy.eks_assume_core_schema_registry_role.arn
}
