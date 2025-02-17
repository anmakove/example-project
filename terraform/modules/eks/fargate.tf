module "fargate_profile" {
  source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
  version = "~> 19.15"

  name         = "fargate-profile"
  cluster_name = module.eks.cluster_id
  subnet_ids   = lookup(local.private_subnets_azs, var.eks_application_workers_asg_config.availability_zone, local.subnets[0])
  selectors = [{
    namespace = var.jenkins_agents_ns
    labels = {
      profile = "fargate"
    }
  }]
}
