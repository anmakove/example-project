######
# RDS Aurora for Platform services
######
resource "aws_db_subnet_group" "platform" {
  name       = "${local.name_prefix}-db"
  subnet_ids = var.db_private_subnets
  tags       = local.tags
}

resource "aws_db_parameter_group" "platform" {
  name_prefix = "${local.name_prefix}-db-aurora-db-postgres14-parameter-group"
  family      = "aurora-postgresql14"
  description = "Parameter group for ${local.name_prefix}-db Aurora cluster with PostgreSQL 14 engine"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "platform" {
  name_prefix = "${local.name_prefix}-db-aurora-postgres14-cluster-parameter-group"
  family      = "aurora-postgresql14"
  description = "Cluster parameter group for ${local.name_prefix}-db Aurora cluster with PostgreSQL 14 engine"
  tags        = local.tags
}

resource "random_password" "db_platform_user_password" {
  length  = 20
  special = false

  lifecycle {
    ignore_changes = [special]
  }
}

module "platform_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.3.0"

  name           = "${local.name_prefix}-db"
  engine         = var.db_platform_config.family
  engine_version = var.db_platform_config.version
  instance_class = var.db_platform_config.instance_class
  instances      = { 1 = {} }

  vpc_id                              = var.db_vpc_id
  db_subnet_group_name                = aws_db_subnet_group.platform.id
  create_db_subnet_group              = false
  create_security_group               = false
  vpc_security_group_ids              = [aws_security_group.platform_db.id]
  allowed_cidr_blocks                 = []
  iam_database_authentication_enabled = true
  database_name                       = var.db_platform_config.database_name
  master_username                     = var.db_platform_config.admin_username
  master_password                     = random_password.db_platform_user_password.result
  publicly_accessible                 = false
  backup_retention_period             = var.db_platform_config.backup_retention_period
  autoscaling_enabled                 = true
  autoscaling_min_capacity            = 1
  autoscaling_max_capacity            = 5
  create_random_password              = false

  ca_cert_identifier = var.db_platform_config.ca_cert_identifier

  deletion_protection = var.env == "dev" ? false : true
  monitoring_interval = 0

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.platform.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.platform.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = local.tags
}

resource "aws_security_group" "platform_db" {
  name        = "${local.name_prefix}-db"
  vpc_id      = var.db_vpc_id
  description = "Security Group for Platform database"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"
    #    security_groups = [aws_security_group.eks_application_workers.id]
    security_groups = var.sg_allowed_security_groups
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = var.sg_allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # nosecuritycheck: Exception for normal nodes work
  }

  tags = local.tags
}

# We need to run this only once per RDS instance.
# We use this module to run initial setup (create default RO & RW roles and users).
module "postgresql_platform_db_init" {
  source = "git::git@github.com:surprise-hr/terraform-module-postgresql.git?ref=v1.2.0"

  run_default_setup = true
}
