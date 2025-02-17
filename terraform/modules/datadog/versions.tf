terraform {
  # Verified on version 1.2.5
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.14.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.23"
    }
  }
}

##################
# DataDog provider
##################
provider "datadog" {
  api_key = lookup(jsondecode(data.vault_kv_secret_v2.datadog.data_json), "api-key")
  app_key = lookup(jsondecode(data.vault_kv_secret_v2.datadog.data_json), "app-key")
  api_url = var.datadog_api_url
}
