data "aws_iam_policy_document" "cognito" {
  count = var.service_components.cognito.enabled ? 1 : 0
  statement {
    sid    = "CognitoUserPool"
    effect = "Allow"
    actions = [
      "cognito-idp:SignUp",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:InitiateAuth",
      "cognito-idp:AdminRespondToAuthChallenge",
      "cognito-idp:AdminUpdateUserAttributes",
      "cognito-idp:RespondToAuthChallenge"
    ]
    resources = [var.service_components.cognito.aws_cognito_user_pool_accounts_arn]
  }
}

resource "aws_iam_policy" "cognito" {
  count       = var.service_components.cognito.enabled ? 1 : 0
  name        = "eks-${var.eks.cluster_name}-sa-${var.service_name}-cognito"
  description = "EKS ${var.eks.cluster_name} SA service policy"
  policy      = data.aws_iam_policy_document.cognito[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cognito" {
  count      = var.service_components.cognito.enabled ? 1 : 0
  policy_arn = aws_iam_policy.cognito[0].arn
  role       = aws_iam_role.sa[0].name
}
