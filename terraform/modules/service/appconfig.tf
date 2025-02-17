#####
# AWS AppConfig
#####
/*
 AWS AppConfig application with configuration profile for ds-{service} config
 Configuration profiles content is managed manually
*/

resource "aws_appconfig_application" "this" {
  count       = var.service_components.appconfig.enabled ? 1 : 0
  name        = "${var.account_prefix}-${var.env}-${var.service_name}"
  description = "AppConfig Application for ${var.service_name} in the ${var.env} environment"
  tags        = local.tags
}

resource "aws_appconfig_environment" "this" {
  count          = var.service_components.appconfig.enabled ? 1 : 0
  name           = var.env # as environment attaches to the application
  description    = "AppConfig Environment for ${var.service_name} in the ${var.env} environment"
  application_id = aws_appconfig_application.this[0].id
  tags           = local.tags
  depends_on     = [aws_appconfig_application.this]
}

resource "aws_appconfig_configuration_profile" "this" {
  for_each = toset([
    for v in var.service_components.appconfig.profiles : v
    if var.service_components.appconfig.enabled
  ])
  name           = each.value
  description    = "AppConfig Configuration Profile ${each.value} for ${var.service_name} in ${var.env} env"
  location_uri   = "hosted"
  application_id = aws_appconfig_application.this[0].id
  /*
  @todo add validators with JSON_SCHEMA or custom LAMBDA
  validator {
    content = aws_lambda_function.app_config_validator.arn
    type    = "LAMBDA"
  }
  */
  tags       = local.tags
  depends_on = [aws_appconfig_application.this]
}

data "aws_iam_policy_document" "appconfig" {
  count = var.service_components.appconfig.enabled ? 1 : 0
  statement {
    sid    = "AppConfigAccess"
    effect = "Allow"
    actions = [
      "appconfig:GetApplication",
      "appconfig:GetEnvironment",
      "appconfig:GetConfigurationProfile",
      "appconfig:GetLatestConfiguration",
      "appconfig:GetHostedConfigurationVersion",
      "appconfig:GetConfiguration",
      "appconfig:StartConfigurationSession",
    ]
    resources = [
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/environment/${aws_appconfig_environment.this[0].environment_id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/configurationprofile/*",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/environment/${aws_appconfig_environment.this[0].environment_id}/configuration/*",
    ]
  }
}

data "aws_iam_policy_document" "appconfig_extra" {
  count = var.service_components.appconfig.enabled ? 1 : 0
  statement {
    sid    = "AppConfigAccessExtra"
    effect = "Allow"
    actions = [
      "appconfig:ListApplications",
      "appconfig:GetApplication",
      "appconfig:GetLatestConfiguration",
      "appconfig:ValidateConfiguration",
      "appconfig:ListConfigurationProfiles",
      "appconfig:GetConfigurationProfile",
      "appconfig:CreateConfigurationProfile",
      "appconfig:UpdateConfigurationProfile",
      "appconfig:ListHostedConfigurationVersions",
      "appconfig:GetHostedConfigurationVersion",
      "appconfig:CreateHostedConfigurationVersion",
      "appconfig:ListDeployments",
      "appconfig:GetDeployment",
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:ListEnvironments",
      "appconfig:GetEnvironment",
      "appconfig:GetConfiguration",
      "appconfig:StartConfigurationSession"
    ]
    resources = [
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/environment/${aws_appconfig_environment.this[0].environment_id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/configurationprofile/*",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/environment/${aws_appconfig_environment.this[0].environment_id}/configuration/*",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${aws_appconfig_application.this[0].id}/environment/${aws_appconfig_environment.this[0].environment_id}/deployment/*",
      "arn:aws:appconfig:${var.region}:${var.account_id}:deploymentstrategy/*"
    ]
  }
  statement {
    sid    = "AppConfigDeploymentStratsAccess"
    effect = "Allow"
    actions = [
      "appconfig:ListDeploymentStrategies",
      "appconfig:GetDeploymentStrategy",
      "appconfig:CreateDeploymentStrategy"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "appconfig" {
  count       = var.service_components.appconfig.enabled ? 1 : 0
  name        = "${var.eks.cluster_name}-sa-${var.service_name}-appconfig"
  description = "EKS ${var.eks.cluster_name} SA ${var.service_name} policy"
  policy      = var.service_components.appconfig.extra ? data.aws_iam_policy_document.appconfig_extra[0].json : data.aws_iam_policy_document.appconfig[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "appconfig" {
  count      = var.service_components.appconfig.enabled ? 1 : 0
  policy_arn = aws_iam_policy.appconfig[0].arn
  role       = aws_iam_role.sa[0].name
}

/*
  Custom policy
*/
data "aws_iam_policy_document" "appconfig_custom" {
  count = var.service_components.appconfig.custom ? 1 : 0
  statement {
    sid    = "AppConfigAccess"
    effect = "Allow"
    actions = [
      "appconfig:GetApplication",
      "appconfig:GetEnvironment",
      "appconfig:GetConfigurationProfile",
      "appconfig:GetLatestConfiguration",
      "appconfig:GetHostedConfigurationVersion",
      "appconfig:GetConfiguration",
      "appconfig:StartConfigurationSession",
    ]
    resources = [
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${var.service_components.appconfig.custom_appconfig_id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${var.service_components.appconfig.custom_appconfig_id}/environment/${var.service_components.appconfig.custom_appconfig_env_id}",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${var.service_components.appconfig.custom_appconfig_id}/configurationprofile/*",
      "arn:aws:appconfig:${var.region}:${var.account_id}:application/${var.service_components.appconfig.custom_appconfig_id}/environment/${var.service_components.appconfig.custom_appconfig_env_id}/configuration/*",
    ]
  }
}

resource "aws_iam_policy" "appconfig_custom" {
  count       = var.service_components.appconfig.custom ? 1 : 0
  name        = "${var.eks.cluster_name}-sa-${var.service_name}-appconfig-custom"
  description = "EKS ${var.eks.cluster_name} SA ${var.service_name} policy"
  policy      = data.aws_iam_policy_document.appconfig_custom[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "appconfig_custom" {
  count      = var.service_components.appconfig.custom ? 1 : 0
  policy_arn = aws_iam_policy.appconfig_custom[0].arn
  role       = aws_iam_role.sa[0].name
}
