# tflint-ignore: terraform_standard_module_structure
variable "iam_sso_admin_role_name_prefix" {
  description = "IAM Admin role ARN in an account created by AWS SSO"
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess"
}

# IAM roles created by AWS SSO
data "aws_iam_roles" "sso_administrator" {
  name_regex  = var.iam_sso_admin_role_name_prefix
  path_prefix = "/aws-reserved/sso.amazonaws.com/${var.region}/"
}

## KMS key for Atlantis gh app
data "aws_iam_policy_document" "this" {
  statement {
    sid = "KMSAdmin"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.master_account_id}:root",
        "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole",
        tolist(data.aws_iam_roles.sso_administrator.arns)[0],
        "arn:aws:iam::${var.account_id}:role/${var.iam_admin_role_name}",
      ]
    }
  }

  statement {
    sid = "KMSPowerUser"

    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:ReEncrypt*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*",
    ]

    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/delegatedadmin/developer/atlantis-ecs_task_execution",
        "arn:aws:iam::${var.account_id}:role/${var.iam_infra_ci_cd_role_name}",
        "arn:aws:iam::${var.account_id}:role/platform-services-prod-admin-shared-terraform",
      ]
    }
  }
}

resource "aws_kms_key" "this" {
  description             = "Encryption key for Atlantis GitHub App"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.this.json

  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/Atlantis-GitHub-App"
  target_key_id = aws_kms_key.this.key_id

  lifecycle {
    prevent_destroy = true
  }
}
