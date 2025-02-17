data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name_prefix
  cidr = var.vpc_cidr

  azs             = local.availability_zone_list
  private_subnets = local.private_subnet_cidr_list
  public_subnets  = local.public_subnet_cidr_list

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_dns_hostnames = true

  tags                     = local.tags
  vpc_tags                 = local.tags
  public_subnet_tags       = local.public_subnet_tags
  private_subnet_tags      = local.private_subnet_tags
  public_route_table_tags  = local.public_route_table_tags
  private_route_table_tags = local.private_route_table_tags

  manage_default_security_group = false
  manage_default_route_table    = false
  manage_default_network_acl    = false

  map_public_ip_on_launch = true
}

module "db_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-db"
  cidr = var.db_vpc_cidr

  azs             = local.availability_zone_list
  private_subnets = local.db_private_subnet_cidr_list

  enable_dns_hostnames = true

  tags                     = local.tags
  private_subnet_tags      = local.db_private_subnet_tags
  private_route_table_tags = local.db_private_route_table_tags

  manage_default_security_group = false
  manage_default_route_table    = false
  manage_default_network_acl    = false

}

# Peering between EKS and DB VPCs
resource "aws_vpc_peering_connection" "eks_db" {
  depends_on = [module.db_vpc]

  peer_owner_id = var.account_id
  peer_vpc_id   = module.db_vpc.vpc_id
  vpc_id        = module.vpc.vpc_id
  auto_accept   = true

  tags = merge(
    {
      Name = "db-vpc"
    },
  local.tags)
}

resource "aws_route" "eks_to_db" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id            = element(module.vpc.private_route_table_ids, count.index)
  destination_cidr_block    = module.db_vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eks_db.id
}

resource "aws_route" "db_to_eks" {
  count = length(module.db_vpc.private_route_table_ids)

  route_table_id            = element(module.db_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eks_db.id
}

resource "aws_route" "public_eks_to_db" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id            = element(module.vpc.public_route_table_ids, count.index)
  destination_cidr_block    = module.db_vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eks_db.id
}

#VPC Endpoint
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = { Name = "s3-vpc-endpoint" }
    },
    cloudwatch_logs = {
      service            = "logs"
      security_group_ids = [aws_security_group.cloudwatch_logs_vpc_endpoint.id]
      subnet_ids         = module.vpc.private_subnets
      tags               = { Name = "cloudwatch-logs-vpc-endpoint" }
    }
  }

  tags = local.tags
}

################################
# CloudWatch Logs VPC endpoint security group and rules
################################
resource "aws_security_group" "cloudwatch_logs_vpc_endpoint" {

  name        = "${local.name_prefix}-cloudwatch-logs-vpc-endpoint"
  vpc_id      = module.vpc.vpc_id
  description = "Security Group for CloudWatch Logs VPC endpoint"

  ingress {
    description = "Ingress from VPC"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Egress all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # nosecuritycheck: Exception for normal nodes work
  }

  tags = merge(
    {
      Name = "${local.name_prefix}-cloudwatch-logs-vpc-endpoint"
    },
    local.tags
  )
}
