dependency "provider_k8s" {
  config_path                             = "../eks"
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
generate "provider_k8s" {
  path      = "generated_provider_k8s.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.provider_k8s.outputs.eks.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.provider_k8s.outputs.eks.cluster_certificate_authority_data}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.provider_k8s.outputs.eks.cluster_id}"]
    command     = "aws"
  }
}
EOF
}
