variable "aws_integration_enabled" {
  description = "Whether to enable DatDog AWS integration or not"
  type        = bool
}

variable "env" {
  description = "Environment name"
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

variable "eks_cluster_name" {
  description = "The name/id of the EKS cluster."
  type        = string
}

variable "datadog_api_url" {
  description = "DataDog API url"
  type        = string
  default     = "https://api.us5.datadoghq.com/"
}

variable "datadog_agent_features" {
  description = "List of Enabled/Disabled DataDog agent features"
  type = object({
    dogstatsd_enabled               = bool
    kube_state_metrics_core_enabled = bool
    logs_enabled                    = bool
    network_monitoring_enabled      = bool
    process_agent_enabled           = bool
    service_monitoring_enabled      = bool
  })
}

variable "datadog_agent_affinity" {
  description = "Affinity configuration for DataDog agent daemonset"
  type        = any
  default     = {}
}

variable "available_aws_regions" {
  description = "List of AWS regions available for DD integration"
  type        = list(string)
}
