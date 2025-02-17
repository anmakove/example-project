resource "aws_security_group" "eks_sys_workers" {
  name        = "eks-${local.eks_cluster_name}-system-workers"
  vpc_id      = var.vpc_id
  description = "Security Group for EKS system worker nodes"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # nosecuritycheck: Exception for normal nodes work
  }

  tags = merge(
    {
      Name = "eks-${local.eks_cluster_name}-system-workers"
    },
    local.tags
  )
}

