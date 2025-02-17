output "eks_cluster_name" {
  description = "AWS EKS cluster name"
  value       = module.eks.cluster_id
}

output "eks" {
  description = "Platform EKS cluster information"
  sensitive   = true
  value       = module.eks
}

output "security_groups" {
  description = "Map of created Security Groups IDs"
  value = {
    (aws_security_group.eks_sys_workers.name)         = aws_security_group.eks_sys_workers.id
    (aws_security_group.eks_application_workers.name) = aws_security_group.eks_application_workers.id
  }
}

