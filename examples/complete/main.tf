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

module "complete_waf" {
  source                 = "./../.."
  name                   = var.name
  description            = var.description
  tags                   = local.tags
  web_acl_resource_arn   = module.alb.lb_arn
  depends_on             = [module.alb]
  create_acl_association = var.create_acl_association
  custom_response_bodies = [
    {
      key          = "custom_response_body_1",
      content      = "You are not authorized to access this resource.",
      content_type = "TEXT_PLAIN"
    }
  ]

  default_action = "allow"

  rules = [
    {
      name     = "${var.name}-allow-rule"
      priority = 1

      action = {
        allow = {
          custom_request_handling = {
            insert_header = {
              name  = var.custom_header_name
              value = var.custom_header_value
            }
          }
        }
      }

      statement = {
        geo_match_statement = {
          country_codes = ["GB"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-allow-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name       = "${var.name}-block-rule"
      priority   = 4
      rule_label = ["ExampleLabel"]
      action = {
        block = {
          custom_response = {
            custom_response_body_key = "custom_response_body_1"
            response_code            = 412
            response_headers = [
              {
                name  = "X-Custom-Header-1"
                value = "You are not authorized to access this resource."
              },
            ]
          }
        }
      }
      statement = {
        geo_match_statement = {
          country_codes = ["US"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-block-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name     = "${var.name}-captcha"
      priority = 2

      action = {
        captcha = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["NL"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-captcha-metric"
        sampled_requests_enabled   = false
      }
    },
    {
      name = "${var.name}-none-override"
      override_action = {
        none = {}
      }
      priority = 5
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-count-override"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },

  ]
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}

module "waf_with_cloudfront" {
  providers = { aws = aws.cloudfront }
  source    = "./../.."
  name      = "${var.name}-cloudfront"
  scope     = var.scope
  rules = [
    {
      name = "${var.name}-count-override"
      override_action = {
        count = {}
      }
      priority = 1
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-count-override"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name     = "${var.name}-challenge"
      priority = 2

      action = {
        challenge = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["NL"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-challenge-metric"
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "${var.name}-count"
      priority = 3

      action = {
        count = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["GB"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-count-metric"
        sampled_requests_enabled   = false
      }
    },
  ]
}
