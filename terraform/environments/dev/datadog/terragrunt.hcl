include "root" {
  path = find_in_parent_folders()
}
include "provider_helm" {
  path = find_in_parent_folders("includes/provider_helm.hcl")
}
include "provider_vault" {
  path = find_in_parent_folders("includes/provider_vault.hcl")
}

include "provider_k8s" {
  path = find_in_parent_folders("includes/provider_k8s.hcl")
}

terraform {
  source = "${path_relative_from_include("root")}/modules//datadog"
}

dependencies {
  paths = ["../eks"]
}

dependency "eks" {
  config_path = "../eks"

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    eks = {
      cluster_id              = "mock"
      cluster_oidc_issuer_url = "mock"
      oidc_provider_arn       = "mock"
    }
  }
}

inputs = {
  eks_cluster_info = {
    cluster_id              = dependency.eks.outputs.eks.cluster_id
    cluster_oidc_issuer_url = dependency.eks.outputs.eks.cluster_oidc_issuer_url
    oidc_provider_arn       = dependency.eks.outputs.eks.oidc_provider_arn
  }

  cluster_agent_replicas = 1

  aws_integration_enabled = true

  available_aws_regions = [
    "us-west-2"
  ]

  datadog_monitoring_components = {
    vault_monitoring    = false
    database_monitoring = false
    redis_monitoring    = false
    redshift_monitoring = false
    kube_state_metrics  = true
    helm_check          = true
    logs                = false # Temporary disabled
    network_monitoring  = false
    process_agent       = true
    service_monitoring  = false
  }

  apm_monitoring = {
    socketEnabled = false
    portEnabled   = false
  }
}
