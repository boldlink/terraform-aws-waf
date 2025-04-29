# S3 Bucket for WAF logs
module "waf_logs_s3" {
  source        = "boldlink/s3/aws"
  version       = "2.5.1"
  bucket        = "aws-waf-logs-${var.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  bucket_policy = data.aws_iam_policy_document.waf_logs_s3.json
  lifecycle_configuration = [{
    id      = "waf-logs-cleanup"
    enabled = true
    filter = {
      object_size_greater_than = 0
    }
    expiration = {
      days = 90 # Expire logs after 90 days
    }
    transition = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }]
  }]
  tags = merge(local.tags, {
    Name = "aws-waf-logs-${var.name}-${local.account_id}"
  })
}

# IAM role for the Firehose delivery stream
resource "aws_iam_role" "firehose_waf_logs" {
  name = "firehose-waf-logs-role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

# IAM policy for the Firehose role
resource "aws_iam_role_policy" "firehose_waf_logs" {
  name = "firehose-waf-logs-policy-${var.name}"
  role = aws_iam_role.firehose_waf_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          module.waf_logs_s3.arn,
          "${module.waf_logs_s3.arn}/*"
        ]
      }
    ]
  })
}

# Kinesis Firehose delivery stream for WAF logs
resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  name        = "aws-waf-logs-${var.name}"
  destination = "extended_s3"
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_waf_logs.arn
    bucket_arn = module.waf_logs_s3.arn
    prefix     = "AWSLogs/${data.aws_caller_identity.current.account_id}/WAF/"
    # Correct parameter names for AWS provider v5.x
    buffering_interval = 300
    buffering_size     = 5
  }
  tags = merge(local.tags, {
    Name = "firehose-waf-logs-${var.name}"
  })
}

module "access_logs_s3" {
  source        = "boldlink/s3/aws"
  version       = "2.5.1"
  bucket        = "${var.name}-${local.account_id}"
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
  create_acl_association = var.create_acl_association

  # Custom response bodies configuration
  custom_response_bodies = [
    {
      key          = "custom_response_body_1"
      content      = "You are not authorized to access this resource."
      content_type = "TEXT_PLAIN"
    }
  ]

  # Enable logging with Kinesis Firehose to S3
  enable_logging          = true
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]

  # Simplified redacted_fields - only supporting single_header for now
  redacted_fields = [
    {
      single_header = {
        name = "authorization"
      }
    },
    {
      single_header = {
        name = "x-api-key"
      }
    }
  ]

  # Logging filter configuration
  logging_filter = {
    default_behavior = "KEEP"
    filters = [
      {
        behavior    = "DROP"
        requirement = "MEETS_ANY"
        conditions = [
          {
            action_condition = "COUNT"
          }
        ]
      }
    ]
  }

  rules = [
    # CORS rule for domains ending with boldlink.io
    {
      name     = "${var.name}-cors-sciensus"
      priority = 1
      action = {
        allow = {}
      }
      statement = {
        byte_match_statement = {
          search_string         = "boldlink.io"
          positional_constraint = "ENDS_WITH"
          field_to_match = {
            single_header = {
              name = "origin"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-cors-sciensus-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },

    # CORS rule for domains ending with bravolink.io
    {
      name     = "${var.name}-cors-vinehealth"
      priority = 2
      action = {
        allow = {}
      }
      statement = {
        byte_match_statement = {
          search_string         = "bravolink.io"
          positional_constraint = "ENDS_WITH"
          field_to_match = {
            single_header = {
              name = "origin"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-cors-vinehealth-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },

    # CORS preflight OPTIONS rule
    {
      name     = "${var.name}-cors-preflight"
      priority = 3
      action = {
        allow = {}
      }
      statement = {
        byte_match_statement = {
          search_string         = "options"
          positional_constraint = "EXACTLY"
          field_to_match = {
            method = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-cors-preflight-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },

    # Allow requests from Great Britain
    {
      name     = "${var.name}-allow-rule"
      priority = 4
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

    # Block requests from the United States
    {
      name       = "${var.name}-block-rule"
      priority   = 7
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

    # CAPTCHA for requests from Netherlands
    {
      name     = "${var.name}-captcha"
      priority = 5
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

    # AWS Common Rule Set with no override
    {
      name = "${var.name}-none-override"
      override_action = {
        none = {}
      }
      priority = 8
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-common-rule-none-override"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },

    # SQL Injection Protection Rule Set
    {
      name = "${var.name}-sqli-protection"
      override_action = {
        none = {}
      }
      priority = 6
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
          version     = "Version_2.0"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-sqli-protection"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
  ]
}

# CloudWatch Log Group for CloudFront WAF logs
resource "aws_cloudwatch_log_group" "waf_cloudfront_logs" {
  provider          = aws.cloudfront
  name              = "aws-waf-logs-cloudfront-${var.name}"
  retention_in_days = 30
  tags              = local.tags
}

module "waf_with_cloudfront" {
  providers = {
    aws = aws.cloudfront
  }
  source = "./../.."
  name   = "${var.name}-cloudfront"
  scope  = var.scope
  # Enable logging with CloudWatch Log Group
  enable_logging          = true
  log_destination_configs = [aws_cloudwatch_log_group.waf_cloudfront_logs.arn]
  # Simplified redacted_fields for CloudFront example
  redacted_fields = [
    {
      single_header = {
        name = "cookie"
      }
    },
    {
      single_header = {
        name = "authorization"
      }
    }
  ]
  # Logging filter configuration
  logging_filter = {
    default_behavior = "KEEP"
    filters = [
      {
        behavior    = "DROP"
        requirement = "MEETS_ALL"
        conditions = [
          {
            action_condition = "COUNT"
          }
        ]
      }
    ]
  }
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
    # CORS rules for CloudFront
    {
      name     = "${var.name}-cf-cors-sciensus"
      priority = 2
      action = {
        allow = {}
      }
      statement = {
        byte_match_statement = {
          search_string         = "stg.sciensus.com"
          positional_constraint = "ENDS_WITH"
          field_to_match = {
            single_header = {
              name = "origin"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-cf-cors-sciensus-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name     = "${var.name}-cf-cors-vinehealth"
      priority = 3
      action = {
        allow = {}
      }
      statement = {
        byte_match_statement = {
          search_string         = ".vinehealth.com"
          positional_constraint = "ENDS_WITH"
          field_to_match = {
            single_header = {
              name = "origin"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-cf-cors-vinehealth-metric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    },
    {
      name     = "${var.name}-challenge"
      priority = 4
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
      priority = 5
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
  depends_on = [aws_cloudwatch_log_group.waf_cloudfront_logs]
}

module "waf_s3" {
  source                  = "./../.."
  name                    = "${var.name}-s3"
  enable_logging          = true
  log_destination_configs = [module.waf_logs_s3.arn]
  tags                    = local.tags
  depends_on = [module.waf_logs_s3]
}


