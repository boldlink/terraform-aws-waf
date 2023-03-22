module "access_logs_s3" {
  source        = "boldlink/s3/aws"
  bucket        = var.name
  bucket_policy = data.aws_iam_policy_document.s3.json
  force_destroy = true
  tags          = local.tags
}

module "alb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_2: "Ensure ALB protocol is HTTPS"
  source                     = "boldlink/lb/aws"
  version                    = "1.0.8"
  name                       = var.name
  internal                   = false
  enable_deletion_protection = false
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnets
  tags                       = local.tags

  access_logs = {
    bucket  = module.access_logs_s3.bucket
    enabled = true
  }

  ingress_rules = {
    http = {
      description = "allow http"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress_rules = {
    default = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "waf" {
  source                 = "./../.."
  name                   = var.name
  tags                   = local.tags
  web_acl_resource_arn   = module.alb.lb_arn
  depends_on             = [module.alb]
  create_acl_association = true

  rules = [
    {
      name     = var.rule_name
      priority = 3

      action = {
        allow = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["KE"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-metric"
        sampled_requests_enabled   = false
      }
    }
  ]
}
