# Test repository
This repository contains example project. It contains Terraform/Terragrunt code and Helm chart.

## Terraform/Terragrunt
Directory `terraform` contains Terraform/Terragrunt code. Terraform modules located in `modules` dir and Terragrunt modules located in `environments/dev` directory.
Modules organizad in a way that entire environment can be created with `terragrunt run-all apply` command and destroyed with `terragrunt run-all destroy` (just set Terragrunt working dir to `terraform/environments/dev`).

Code is intended to set up VPC, domain zone, EKS cluster and another dependencies for some example service. Here the also code present for setting up basic infrastructire for the example service itself.
Also here the example DataDog integration present to integrate EKS cluster and AWS account with DataDog.

### WARNING
Due to the security requirements all things that lead to the actual AWS accounts or repositories (or S3 buckets, etc) were changed to use mocked values (like example.com). 
Because of this Terragrunt can't be executed (and even initialized) as-is (there will be errors related to non-existent S3 buckets, GitHub organization, AWS accounts, domains, etc).
Due to the same security requirements all secrets.yaml files remain unencrypted (because reviewer doesn't have access to an encryptment material).

## Helm chart
Directory `helm` contains pseudo-unified Helm chart that can be used for Java service deployments. Helm Chart contains a lot of default values that can be owerwritten for each service.
