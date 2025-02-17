locals {
  name_prefix = var.account_name

  tags = merge(var.tags, {})

  availability_zone_list   = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnet_cidr_list = [cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1), cidrsubnet(var.vpc_cidr, 4, 2)]
  public_subnet_cidr_list  = [cidrsubnet(var.vpc_cidr, 6, 32), cidrsubnet(var.vpc_cidr, 6, 36), cidrsubnet(var.vpc_cidr, 6, 40)]
  private_subnets_azs      = [for k, v in data.aws_subnet.private : { "availability_zone_id" = v.availability_zone_id, "subnet_id" = v.id }]
  private_subnets_info     = { for k, v in data.aws_subnet.private : v.cidr_block => { "availability_zone" = v.availability_zone, "availability_zone_id" = v.availability_zone_id, "subnet_id" = v.id, "subnet_cidr" = v.cidr_block } }
  public_subnets_info      = { for k, v in data.aws_subnet.public : v.cidr_block => { "availability_zone" = v.availability_zone, "availability_zone_id" = v.availability_zone_id, "subnet_id" = v.id, "subnet_cidr" = v.cidr_block } }

  db_private_subnet_cidr_list = [cidrsubnet(var.db_vpc_cidr, 4, 0), cidrsubnet(var.db_vpc_cidr, 4, 1), cidrsubnet(var.db_vpc_cidr, 4, 2)]
  db_private_subnets_info     = { for k, v in data.aws_subnet.db_private : v.cidr_block => { "availability_zone" = v.availability_zone, "availability_zone_id" = v.availability_zone_id, "subnet_id" = v.id, "subnet_cidr" = v.cidr_block } }

  public_subnet_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-public"
    },
    local.eks_public_subnet_tags,
    local.tags
  )

  private_subnet_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-private"
    },
    local.eks_private_subnet_tags,
    local.tags
  )

  public_route_table_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-public"
    },
    local.tags
  )

  private_route_table_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-private"
    },
    local.tags
  )

  eks_public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  eks_private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  db_private_subnet_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-db-private"
    },
    local.tags
  )

  db_private_route_table_tags = merge(
    {
      "Name" = "${local.name_prefix}-${var.region}-db-private"
    },
    local.tags
  )
}
