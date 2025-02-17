terraform {
  # Verified on version 1.2.5
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.38.0"
    }
  }
}

provider "github" {}
