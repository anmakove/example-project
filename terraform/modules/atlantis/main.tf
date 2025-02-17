##############################################################
# Atlantis Service
##############################################################

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "3.28.0"

  name = local.name

  # VPC
  vpc_id             = var.vpc_id
  azs                = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  # Disable EFS and use ephemeral storage
  enable_ephemeral_storage = true
  ephemeral_storage_size   = 100
  user                     = "100:1000"

  # ECS
  ecs_service_platform_version = "LATEST"
  ecs_container_insights       = true
  ecs_task_cpu                 = 4096
  ecs_task_memory              = 8192
  container_memory_reservation = 6144

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  entrypoint        = ["docker-entrypoint.sh"]
  command           = ["server"]
  working_directory = "/tmp"
  docker_labels = {
    "org.opencontainers.image.title"       = "Atlantis"
    "org.opencontainers.image.description" = "A self-hosted golang application that listens for Terraform pull request events via webhooks."
    "org.opencontainers.image.url"         = "https://github.com/runatlantis/atlantis/pkgs/container/atlantis"
  }
  start_timeout = 30
  stop_timeout  = 30

  readonly_root_filesystem = false # atlantis currently mutable access to root filesystem
  ulimits = [{
    name      = "nofile"
    softLimit = 4096
    hardLimit = 16384
  }]

  # DNS
  create_route53_record = false
  route53_zone_name     = var.domain
  certificate_arn       = var.certificate_arn

  # Trusted roles
  trusted_principals = ["ssm.amazonaws.com"]

  # IAM role options
  #  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cloud/developer-boundary-policy"
  path = "/delegatedadmin/developer/"

  # Bootstrapping a new Github App
  atlantis_github_user       = var.bootstrap_github_app ? "fake" : ""
  atlantis_github_user_token = var.bootstrap_github_app ? "fake" : ""

  # Atlantis w/ GitHub app
  ################################################################################
  # Suggestion: instead of allocating the values of the atlantis_github_app_key
  # and atlantis_github_webhook_secret in the tfvars file,it is suggested to
  # upload the values in the AWS Parameter Store of the atlantis account and
  # call the values via the data source function
  # (e.g. data.aws_ssm_parameter.ghapp_key.value) for security reasons.
  ################################################################################

  atlantis_github_app_id         = var.bootstrap_github_app ? "" : var.github_app_id
  atlantis_github_app_key        = var.bootstrap_github_app ? "" : var.github_app_key
  atlantis_github_webhook_secret = var.bootstrap_github_app ? "" : var.github_webhook_secret
  atlantis_repo_allowlist        = var.atlantis_repo_allowlist
  atlantis_image                 = var.atlantis_image
  # ALB access
  alb_ingress_cidr_blocks = local.alb_ingress_ipv4_cidr_blocks

  alb_authenticate_oidc = {
    issuer                              = "https://accounts.google.com"
    token_endpoint                      = "https://oauth2.googleapis.com/token"
    user_info_endpoint                  = "https://openidconnect.googleapis.com/v1/userinfo"
    authorization_endpoint              = "https://accounts.google.com/o/oauth2/v2/auth"
    authentication_request_extra_params = {}
    client_id                           = var.oidc_client_id
    client_secret                       = var.oidc_client_secret
  }

  alb_logging_enabled                  = true
  alb_log_bucket_name                  = module.atlantis_access_log_bucket.s3_bucket_id
  alb_log_location_prefix              = "atlantis-alb"
  alb_listener_ssl_policy_default      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  alb_drop_invalid_header_fields       = true
  alb_enable_cross_zone_load_balancing = true
  # TODO: disable unauthenticated access
  allow_unauthenticated_access = true

  # Github webhooks allow
  allow_github_webhooks            = true
  github_webhooks_cidr_blocks      = local.github_webhooks_ipv4_cidr_blocks
  github_webhooks_ipv6_cidr_blocks = local.github_webhooks_ipv6_cidr_blocks

  allow_repo_config = true

  # Extra container definitions
  extra_container_definitions = [
    {
      name      = "log-router"
      image     = "amazon/aws-for-fluent-bit:latest"
      essential = true

      firelens_configuration = {
        type = "fluentbit"

        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "firelens-container",
            awslogs-region        = local.region,
            awslogs-create-group  = true,
            awslogs-stream-prefix = "firelens"
          }
        }
      }
    }
  ]

  custom_environment_variables = [
    {
      name : "ATLANTIS_REPO_CONFIG_JSON",
      value : jsonencode(yamldecode(file("${path.module}/server-atlantis.yaml"))),
    },
    {
      name : "ATLANTIS_TERRAFORM_VERSION",
      value : "1.2.9"
    },
    {
      name : "ATLANTIS_PARALLEL_POOL_SIZE",
      value : "3"
    },
  ]
  policies_arn = concat([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ],
  var.policy_arns)

  atlantis_log_level = "info"
  atlantis_fqdn      = "atlantis.${var.domain}"

  tags = local.tags
}

################################################################################
# ALB Access Log Bucket + Policy
################################################################################
module "atlantis_access_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "surprise-atlantis-access-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  attach_policy = true
  policy        = data.aws_iam_policy_document.atlantis_access_log_bucket_policy.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = true

  tags = local.tags

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "all"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_expiration = {
        days = 30
      }
    },
  ]
}

data "aws_iam_policy_document" "atlantis_access_log_bucket_policy" {
  statement {
    sid     = "LogsLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.atlantis_access_log_bucket.s3_bucket_arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
        data.aws_elb_service_account.current.arn,
      ]
    }
  }

  statement {
    sid     = "AWSLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.atlantis_access_log_bucket.s3_bucket_arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid     = "AWSLogDeliveryAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [
      module.atlantis_access_log_bucket.s3_bucket_arn
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }
}
