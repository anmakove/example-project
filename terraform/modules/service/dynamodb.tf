#####
# AWS DynamodDB
#####
resource "aws_dynamodb_table" "this" {
  count          = var.service_components.dynamodb.enabled ? 1 : 0
  name           = "${var.account_prefix}-${var.env}-${var.service_name}"
  billing_mode   = var.env == "prod" ? "PROVISIONED" : "PAY_PER_REQUEST"
  read_capacity  = var.env == "prod" ? 5 : null
  write_capacity = var.env == "prod" ? 5 : null
  hash_key       = "decision_key"
  range_key      = "decided_at"

  attribute {
    name = "decision_key"
    type = "S"
  }

  attribute {
    name = "decided_at"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
  tags = local.tags
}

data "aws_iam_policy_document" "dynamodb" {
  count = var.service_components.dynamodb.enabled ? 1 : 0
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:PartiQLSelect",
      "dynamodb:PartiQLInsert",
      "dynamodb:PartiQLUpdate",
      "dynamodb:PartiQLDelete",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.this[0].id}",
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.this[0].id}/index/*"
    ]
  }
}

resource "aws_iam_policy" "dynamodb" {
  count       = var.service_components.dynamodb.enabled ? 1 : 0
  name        = "eks-${var.eks.cluster_name}-sa-${var.service_name}-dynamodb"
  description = "EKS ${var.eks.cluster_name} SA service policy"
  policy      = data.aws_iam_policy_document.dynamodb[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  count      = var.service_components.dynamodb.enabled ? 1 : 0
  policy_arn = aws_iam_policy.dynamodb[0].arn
  role       = aws_iam_role.sa[0].name
}
