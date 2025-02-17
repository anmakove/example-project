variable "service_name" {
  type        = string
  description = "Service name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region name"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "account_prefix" {
  type        = string
  description = "AWS account prefix"
}

variable "service_components" {
  description = "Parameters collection to create for service"
  type = object({
    namespace = optional(object({
      enabled = bool
      name    = optional(string, "")
    }), { enabled = false, name = "" })
    appconfig = optional(object({
      enabled                 = bool
      profiles                = list(string)
      custom                  = optional(bool, false)
      custom_appconfig_id     = optional(string, "")
      custom_appconfig_env_id = optional(string, "")
      extra                   = optional(bool, false)
    }), { enabled = false, profiles = [], extra = false })
    serviceaccount = optional(object({
      enabled = bool
      jwt_key = optional(bool, false)
    }), { enabled = false, jwt_key = false })
    db = optional(object({
      enabled     = optional(bool, false)
      db_name     = optional(string, "")
      db_username = optional(string, "")
      custom_schema_to_create = optional(list(object({
        schema_name = string
      })), [])
      pg_users_to_create = optional(list(object({
        username = string
        role     = list(string)
      })), [])
      pg_tables_to_publish     = optional(list(string), [])
      pg_extensions_to_install = optional(list(string), [])
      redash_datasource_create = optional(bool, false)
      datadog_enabled          = optional(bool, false)
      deps                     = optional(map(string), {})
      friend_finder            = optional(map(string), {})
    }), { enabled = false })
    s3bucket = optional(object({
      enabled = bool
    }), { enabled = false })
    s3external = optional(object({
      enabled    = bool
      bucket_arn = string
      rw         = optional(bool, false)
    }), { enabled = false, bucket_arn = "", rw = false })
    dynamodb = optional(object({
      enabled = bool
    }), { enabled = false })
    vault = optional(object({
      enabled = bool
      params = list(object({
        name        = string
        value       = string
        description = string
      }))
    }), { enabled = false, params = [] })
    debezium = optional(object({
      enabled          = bool
      connector_config = map(string)
    }), { enabled = false, connector_config = {} })
    cognito = optional(object({
      enabled                            = bool
      aws_cognito_user_pool_accounts_arn = string
    }), { enabled = false, aws_cognito_user_pool_accounts_arn = "" })
  })
}

variable "eks" {
  description = "EKS cluster information"
  type = object({
    cluster_name               = string
    cluster_endpoint           = string
    oidc_provider_arn          = string
    cluster_oidc_issuer_url    = string
    certificate_authority_data = string
  })
}

variable "db_details" {
  description = "DB for service"
  type        = any
}
