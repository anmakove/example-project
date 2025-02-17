module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.18.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = false

  vpc_id  = var.vpc_id
  subnets = [for k, v in var.private_subnets : v.subnet_id]

  worker_groups_launch_template = local.eks_worker_groups_launch_template

  enable_irsa                 = true
  map_roles                   = local.eks_auth_iam_roles_map
  manage_worker_iam_resources = false
  write_kubeconfig            = false

  # Allow communication for Fargate
  worker_create_cluster_primary_security_group_rules = true

  cluster_enabled_log_types     = var.eks_cluster_log_types
  cluster_log_retention_in_days = var.eks_cluster_log_retention

  tags = local.tags
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = module.eks.cluster_id
  addon_name    = "vpc-cni"
  addon_version = try(var.eks_addons.vpc_cni.version, data.aws_eks_addon_version.this["vpc-cni"].version)

  preserve = true

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  configuration_values = jsonencode({
    env = {
      WARM_IP_TARGET = "5"
    }
    livenessProbeTimeoutSeconds  = 5
    readinessProbeTimeoutSeconds = 5
  })
  service_account_role_arn = aws_iam_role.eks_aws_node.arn

  tags = local.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = module.eks.cluster_id
  addon_name    = "kube-proxy"
  addon_version = try(var.eks_addons.kube_proxy.version, data.aws_eks_addon_version.this["kube-proxy"].version)

  preserve = true

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"


  tags = local.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = module.eks.cluster_id
  addon_name    = "coredns"
  addon_version = try(var.eks_addons.coredns.version, data.aws_eks_addon_version.this["coredns"].version)

  preserve = true

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"


  tags = local.tags
}

resource "aws_security_group" "eks_application_workers" {

  name        = "eks-${local.eks_cluster_name}-application-workers"
  description = "Security Group for EKS Application worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # nosecuritycheck: Exception for normal nodes work
  }

  tags = merge(
    {
      Name = "eks-${local.eks_cluster_name}-application-workers"
    },
    local.tags
  )
}
