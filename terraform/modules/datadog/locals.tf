locals {
  # https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml
  datadog_helm_values = {
    registry = "public.ecr.aws/datadog"

    clusterAgent = {
      replicas = 2

      # Container autodiscovery parameters for container monitoring
      containerInclude      = "name:^aws-fluent-bit$ name:^aws-cluster-autoscaler$ name:^aws-load-balancer-controller$"
      containerExclude      = "kube_namespace:^kube-system$ kube_namespace:^datadog$ kube_namespace:^reloader$ kube_namespace:^monitoring$ kube_namespace:^jenkins-agents$"
      excludePauseContainer = true

      confd = {
        # https://docs.datadoghq.com/integrations/http_check/
        "http_check.yaml" = yamlencode({
          cluster_check = true
          instances     = local.http_checks
        })
      }

      env = [
        {
          name  = "DD_ADMISSION_CONTROLLER_AUTO_INSTRUMENTATION_CONTAINER_REGISTRY", # https://docs.datadoghq.com/tracing/trace_collection/library_injection_local/?tab=kubernetes#container-registries
          value = "public.ecr.aws/datadog"
        }
      ]

      nodeSelector = {
        "node.kubernetes.io/instance-group" : "system"
      }
    }

    datadog = {
      apiKey      = lookup(jsondecode(data.vault_kv_secret_v2.datadog.data_json), "api-key")
      site        = "us5.datadoghq.com"
      clusterName = var.eks_cluster_name

      # Container autodiscovery parameters for container monitoring and logging
      containerExcludeLogs = "image:.*"

      containerInclude      = "name:^aws-fluent-bit$ name:^aws-cluster-autoscaler$ name:^aws-load-balancer-controller$"
      containerExclude      = "kube_namespace:^kube-system$ kube_namespace:^datadog$ kube_namespace:^reloader$ kube_namespace:^monitoring$ kube_namespace:^jenkins-agents$"
      excludePauseContainer = true

      dogstatsd = {
        port            = 8225 # Default port is 8125, but it's busy by Cloudwatch agent. Added to Vault as dogstatsd-port https://vault.svc.surprise.dev/ui/vault/secrets/secret/show/services/prod/common/datadog
        useHostPort     = var.datadog_agent_features.dogstatsd_enabled
        nonLocalTraffic = true
      }

      env = [
        {
          name  = "DD_INVENTORIES_CONFIGURATION_ENABLED", # https://docs.datadoghq.com/infrastructure/list/#agent-configuration
          value = true
        },
        /*
        https://docs.datadoghq.com/tracing/guide/ignoring_apm_resources/?tab=kuberneteshelm#ignoring-based-on-resources
        Exclude healthchecks, rollbar requests, metrics endpoints
        */
      ]

      helmCheck = {
        enabled       = true
        collectEvents = true
      }

      kubeStateMetricsCore = {
        enabled = var.datadog_agent_features.kube_state_metrics_core_enabled
      }

      logs = {
        enabled                = var.datadog_agent_features.logs_enabled
        containerCollectAll    = true
        autoMultiLineDetection = true
      }

      networkMonitoring = {
        enabled = var.datadog_agent_features.network_monitoring_enabled
      }

      processAgent = {
        enabled           = var.datadog_agent_features.process_agent_enabled
        processCollection = true
        processDiscovery  = true
      }

      # Universal Service Monitoring
      serviceMonitoring = {
        enabled = var.datadog_agent_features.service_monitoring_enabled
      }

      remoteConfiguration = {
        enabled = true
      }

      tags = ["env:${var.env}", "orchestration:terraform"]
    }

    agents = {
      tolerations = [{ operator = "Exists", effect = "NoSchedule", key = "" }]
      affinity    = var.datadog_agent_affinity
    }

    targetSystem = "linux"
  }
}
