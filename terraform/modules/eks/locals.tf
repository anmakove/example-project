locals {
  name_prefix = var.account_name

  tags = merge(var.tags, {})

  eks_cluster_name = local.name_prefix

  private_subnets_azs = {
    for k, v in var.private_subnets : v.availability_zone => v.subnet_id...
  }

  eks_worker_groups_launch_template_system = {
    ## system workers
    name                                     = var.eks_sys_workers_asg_config.kubelet_label
    instance_type                            = var.eks_sys_workers_asg_config.instance_type
    root_volume_size                         = var.eks_sys_workers_asg_config.root_volume_size
    root_volume_type                         = var.eks_sys_workers_asg_config.root_volume_type
    asg_desired_capacity                     = var.eks_sys_workers_asg_config.asg_desired_capacity
    asg_max_size                             = var.eks_sys_workers_asg_config.asg_max_size
    asg_min_size                             = var.eks_sys_workers_asg_config.asg_min_size
    public_ip                                = false
    kubelet_extra_args                       = "--node-labels=node.kubernetes.io/instance-group=${var.eks_sys_workers_asg_config.kubelet_label}"
    subnets                                  = [for k, v in var.private_subnets : v.subnet_id]
    additional_security_group_ids            = aws_security_group.eks_sys_workers.id
    iam_instance_profile_name                = aws_iam_instance_profile.eks_sys_workers.id
    protect_from_scale_in                    = false
    on_demand_percentage_above_base_capacity = "100"
    termination_policies                     = ["OldestInstance"]
    enabled_metrics                          = var.eks_worker_asg_enabled_metrics_list

    tags = [
      {
        key                 = "k8s.io/cluster-autoscaler/enabled"
        value               = "true"
        propagate_at_launch = false
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${local.eks_cluster_name}"
        value               = "owned"
        propagate_at_launch = false
      },
      {
        key                 = "node.kubernetes.io/instance-group"
        value               = var.eks_sys_workers_asg_config.kubelet_label
        propagate_at_launch = true
      }
    ]
  }

  eks_worker_groups_launch_template_application = {
    name                                     = var.eks_application_workers_asg_config.kubelet_label
    instance_type                            = var.eks_application_workers_asg_config.instance_type
    root_volume_size                         = var.eks_application_workers_asg_config.root_volume_size
    root_volume_type                         = var.eks_application_workers_asg_config.root_volume_type
    asg_desired_capacity                     = "0"
    asg_max_size                             = "1"
    asg_min_size                             = "0"
    public_ip                                = false
    kubelet_extra_args                       = "--node-labels=TechDebt"
    subnets                                  = local.private_subnets_azs[var.eks_application_workers_asg_config.availability_zone]
    additional_security_group_ids            = aws_security_group.eks_application_workers.id
    iam_instance_profile_name                = aws_iam_instance_profile.eks_application_workers.id
    protect_from_scale_in                    = false
    on_demand_percentage_above_base_capacity = "100"
    termination_policies                     = ["OldestInstance"]
    enabled_metrics                          = var.eks_worker_asg_enabled_metrics_list

    tags = [
      {
        key                 = "node.kubernetes.io/instance-group"
        value               = "TechDebt"
        propagate_at_launch = true
      }
    ]
  }

  eks_worker_groups_launch_template_application_az = [
    for subnet in local.subnets : {
      name                                     = "${var.eks_application_workers_asg_config.kubelet_label}-${subnet["availability_zone_id"]}"
      instance_type                            = var.eks_application_workers_asg_config.instance_type
      root_volume_size                         = var.eks_application_workers_asg_config.root_volume_size
      root_volume_type                         = var.eks_application_workers_asg_config.root_volume_type
      asg_desired_capacity                     = var.eks_application_workers_asg_desired_capacity[subnet["availability_zone_id"]]
      asg_max_size                             = var.eks_application_workers_asg_config.asg_max_size
      asg_min_size                             = var.eks_application_workers_asg_min_size[subnet["availability_zone_id"]]
      public_ip                                = false
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/instance-group=${var.eks_application_workers_asg_config.kubelet_label}"
      subnets                                  = [subnet["subnet_id"]]
      additional_security_group_ids            = aws_security_group.eks_application_workers.id
      iam_instance_profile_name                = aws_iam_instance_profile.eks_application_workers.id
      protect_from_scale_in                    = false
      on_demand_percentage_above_base_capacity = "100"
      termination_policies                     = ["OldestInstance"]
      enabled_metrics                          = var.eks_worker_asg_enabled_metrics_list

      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "true"
          propagate_at_launch = false
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${local.eks_cluster_name}"
          value               = "owned"
          propagate_at_launch = false
        },
        {
          key                 = "node.kubernetes.io/instance-group"
          value               = var.eks_application_workers_asg_config.kubelet_label
          propagate_at_launch = true
        }
      ]
    }
  ]

  eks_worker_groups_launch_template = concat([
    local.eks_worker_groups_launch_template_system,
    local.eks_worker_groups_launch_template_application,
    ],
    local.eks_worker_groups_launch_template_application_az
  )

  eks_auth_iam_roles_map = concat([
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/${var.iam_admin_role_name}"
      username = var.iam_admin_role_name
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/${local.iam_sso_admin_role_name}"
      username = local.iam_sso_admin_role_name
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/${var.iam_infra_ci_cd_role_name}"
      username = var.iam_infra_ci_cd_role_name
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
      username = "OrganizationAccountAccessRole"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/${local.iam_sso_secops_role_name}"
      username = local.iam_sso_secops_role_name
      groups   = ["view", "pods-exec"]
    },
    {
      groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
      rolearn  = module.fargate_profile.iam_role_arn
      username = "system:node:{{SessionName}}"

    }
    ],
    [for role in var.aws_auth_additional_roles_map : {
      rolearn  = "arn:aws:iam::${var.account_id}:role/${role.rolename}"
      username = role.username
      groups   = role.groups
      }
    ]
  )

  eks_worker_iam_default_aws_policies = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonSSMManagedInstanceCore",
    "service-role/AmazonEBSCSIDriverPolicy"
  ])

  iam_sso_admin_role_name  = tolist(data.aws_iam_roles.sso_administrator.names)[0]
  iam_sso_secops_role_name = tolist(data.aws_iam_roles.sso_secops.names)[0]

  subnets = [for k, v in var.private_subnets : { "availability_zone_id" = v.availability_zone_id, "subnet_id" = v.subnet_id }]
}
