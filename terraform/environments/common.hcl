/*
  Common Terragrunt inputs for all environments.

  This is included in the root terragrunt.hcl to
  configure the remote state bucket and pass forward to the child modules.
*/
inputs = {
  account_prefix = "platform"

  region = "us-west-2"

  vault_address = "https://vault.svc.example.com"
}
