locals {
  http_checks_envs = ["dev", "qa", "prod"]
  http_checks_domain_name = {
    dev  = "dev.usw2.example.com"
    qa   = "qa.usw2.example.com"
    prod = "usw2.example.com"
  }
  http_checks_min_interval = 60
  http_checks_tags         = { for env in local.http_checks_envs : env => ["env:${env}"] }

  # list of services with unified Java health check endpoint https://<service name>-int.java.<env>.usw2.example.com/actuator/health/liveness
  http_checks_int_java_services = [
    "service1",
    "service2",
    "service3"
  ]

  # list of services with unified DS health check endpoint https://<service name>-int.python.<env>.usw2.example.com/health
  http_checks_int_python_services = [
    "ds-service-1",
    "ds-service-2"
  ]

  http_checks_api_services = flatten([for env in local.http_checks_envs : [for service in local.http_checks_int_java_services :
    {
      name                    = "${service}-int-${env}"
      tls_verify              = "true"
      url                     = "https://${service}-int.java.${local.http_checks_domain_name[env]}/actuator/health/liveness"
      min_collection_interval = local.http_checks_min_interval
      tags                    = local.http_checks_tags[env]
    }
  ]])
  http_checks_ds_services = flatten([for env in local.http_checks_envs : [for service in local.http_checks_int_python_services :
    {
      name                    = "${service}-int-${env}"
      tls_verify              = "true"
      url                     = "https://${service}-int.python.${local.http_checks_domain_name[env]}/health"
      min_collection_interval = local.http_checks_min_interval
      tags                    = local.http_checks_tags[env]
    }
  ]])

  # list of health check endpoints for services with non-unified health checks
  http_checks_other_services = flatten(concat(
    [for env in local.http_checks_envs : [
      # TODO make liveness endpoint conventional
      {
        name                    = "custom-service-1-${env}"
        tls_verify              = "true"
        url                     = "https://custom-service-1.core.${local.http_checks_domain_name[env]}/customhealthcheck"
        min_collection_interval = local.http_checks_min_interval
        tags                    = local.http_checks_tags[env]
      },
    ]],
  ))

  http_checks_prod_only_services = flatten([for env in ["prod"] : [
    {
      name                    = "vault-prod"
      tls_verify              = "true"
      url                     = "https://vault.example.com/v1/sys/health"
      min_collection_interval = local.http_checks_min_interval
      tags                    = local.http_checks_tags[env]
    },
    {
      name                    = "jenkins-prod"
      tls_verify              = "true"
      url                     = "https://jenkins.example.com/login"
      min_collection_interval = local.http_checks_min_interval
      tags                    = local.http_checks_tags[env]
    }
  ]])
  # Form full list of http checks
  http_checks = concat(
    local.http_checks_api_services,
    local.http_checks_ds_services,
    local.http_checks_other_services,
    local.http_checks_prod_only_services
  )
}
