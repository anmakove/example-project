variable "vpc_cidr" {
  description = "Network address block for VPC"
  type        = string
}

variable "single_nat_gateway" {
  description = "Enable Single NAT gateway"
  default     = true
  type        = bool
}

variable "one_nat_gateway_per_az" {
  description = "Enable One NAT gateway per AZ"
  default     = true
  type        = bool
}

variable "db_vpc_cidr" {
  description = "Network address block for DB VPC"
  type        = string
}

variable "tags" {
  description = "List of tags to all resources"
  default     = {}
  type        = map(string)
}

variable "region" {
  description = "AWS region ID"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "account_name" {
  description = "AWS project account name"
  type        = string
}
