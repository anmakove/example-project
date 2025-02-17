dependency "provider_helm" {
  config_path = "../eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  skip_outputs                           = false
  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    eks = {
      cluster_endpoint                   = "mock"
      cluster_certificate_authority_data = "bW9jawo="
      cluster_id                         = "mock"
    }
  }
}
generate "provider_helm" {
  path      = "generated_provider_helm.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# tflint-ignore: all
variable "helm_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "1234567890.dkr.ecr.us-west-2.amazonaws.com"
}
data "aws_ecr_authorization_token" "token" {
  registry_id = split(".", var.helm_chart_repository)[0] # get account id from the Helm chart repository URL
}
provider "helm" {
  kubernetes {
    host                   = "${dependency.provider_helm.outputs.eks.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.provider_helm.outputs.eks.cluster_certificate_authority_data}")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "${dependency.provider_helm.outputs.eks.cluster_id}"]
      command     = "aws"
    }
  }
  registry {
    url      = "oci://1234567890.dkr.ecr.us-west-2.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
EOF
}
