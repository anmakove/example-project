output "vpc" {
  description = "AWS VPC information: subnets, IDs, CIDRs, NAT public IPs, RDS SG ID, CloudWatch VPC endpoint"
  value = {
    vpc_id                      = module.vpc.vpc_id
    vpc_cidr_block              = module.vpc.vpc_cidr_block
    private_subnets             = module.vpc.private_subnets
    private_subnets_info        = local.private_subnets_info
    private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
    public_subnets              = module.vpc.public_subnets
    public_subnets_info         = local.public_subnets_info
    public_subnets_cidr_blocks  = module.vpc.public_subnets_cidr_blocks
    nat_public_ips              = module.vpc.nat_public_ips
    private_route_table_ids     = module.vpc.private_route_table_ids
    cw_logs_vpc_endpoint        = module.vpc_endpoints.endpoints["cloudwatch_logs"].dns_entry[0].dns_name
  }
}

output "private_subnets_azs" {
  description = "List of private subnets with azs"
  value = {
    private_subnets_azs = jsonencode(local.private_subnets_azs)
  }
}

output "db_vpc" {
  description = "AWS VPC information: subnets, IDs, CIDRs, NAT public IPs, RDS SG ID, CloudWatch VPC endpoint"
  value = {
    vpc_id                      = module.db_vpc.vpc_id
    vpc_cidr_block              = module.vpc.vpc_cidr_block
    private_subnets             = module.db_vpc.private_subnets
    private_subnets_info        = local.db_private_subnets_info
    private_subnets_cidr_blocks = module.db_vpc.private_subnets_cidr_blocks
    public_subnets              = module.db_vpc.public_subnets
    public_subnets_cidr_blocks  = module.db_vpc.public_subnets_cidr_blocks
    nat_public_ips              = module.db_vpc.nat_public_ips
    private_route_table_ids     = module.db_vpc.private_route_table_ids
  }
}
