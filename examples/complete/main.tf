module "access_logs_s3" {
  source        = "boldlink/s3/aws"
  bucket        = var.name
  bucket_policy = data.aws_iam_policy_document.s3.json
  force_destroy = var.force_destroy
  tags          = local.tags
}

module "alb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_2: "Ensure ALB protocol is HTTPS"
  source                     = "boldlink/lb/aws"
  version                    = "1.0.8"
  name                       = var.name
  internal                   = var.internal
  enable_deletion_protection = var.enable_deletion_protection
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnets
  tags                       = local.tags

  access_logs = {
    bucket  = module.access_logs_s3.bucket
    enabled = var.access_logs_enabled
  }

  ingress_rules = {
    http = var.http_ingress_rules
  }

  egress_rules = {
    default = var.http_egress_rules
  }
}

module "waf" {
  source                 = "./../.."
  name                   = var.name
  tags                   = local.tags
  web_acl_resource_arn   = module.alb.lb_arn
  depends_on             = [module.alb]
  create_acl_association = var.create_acl_association

  default_action = {
    allow = {
      custom_request_handling = {
        insert_header = {
          name  = var.custom_header_name
          value = var.custom_header_value
        }
      }
    }
  }

  rules = [
    {
      name     = var.rule_name
      priority = var.rule_priority

      action = {
        allow = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = var.country_codes
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  ]
}
