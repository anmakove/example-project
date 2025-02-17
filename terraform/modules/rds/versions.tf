terraform {
  # Verified on version 1.2.5
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.65"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.16"
    }
  }
}
