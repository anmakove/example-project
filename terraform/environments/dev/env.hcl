/*
  Environment-wide Terragrunt inputs.

  This is included in the root terragrunt.hcl to
  configure the remote state bucket and pass forward to the child modules.
*/
inputs = {
  account_id = "123456789012"
}
