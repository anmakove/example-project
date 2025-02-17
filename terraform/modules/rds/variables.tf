variable "tags" {
  description = "List of tags to all resources"
  default     = {}
  type        = map(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "account_name" {
  description = "AWS project account name"
  type        = string
}

variable "db_vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_private_subnets" {
  description = "DB Private subnets list"
  type        = list(string)
}

variable "db_platform_config" {
  description = "Database configurations for Platform services"
  type = object({
    version                 = string
    family                  = string
    instance_class          = string
    port                    = number
    database_name           = string
    admin_username          = string
    maintenance_window      = string
    backup_window           = string
    backup_retention_period = number
    ca_cert_identifier      = string
  })
}

variable "sg_allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for DB SG"
  type        = list(string)
  default     = []
}

variable "sg_allowed_security_groups" {
  description = "Allowed SGs for DB SG"
  type        = list(string)
  default     = []
}
