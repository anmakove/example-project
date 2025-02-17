data "aws_subnet" "private" {
  for_each = toset(local.private_subnet_cidr_list)

  cidr_block = each.key

  depends_on = [module.vpc]
}

data "aws_subnet" "public" {
  for_each = toset(local.public_subnet_cidr_list)

  cidr_block = each.key

  depends_on = [module.vpc]
}

data "aws_subnet" "db_private" {
  for_each = toset(local.db_private_subnet_cidr_list)

  cidr_block = each.key

  depends_on = [module.vpc]
}
