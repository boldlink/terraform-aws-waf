data "aws_caller_identity" "current" {}

data "aws_vpc" "supporting" {
  filter {
    name   = "tag:Name"
    values = [var.supporting_resources_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pub.*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_elb_service_account" "main" {}

### LB Bucket Policy
data "aws_iam_policy_document" "s3" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.name}-${local.account_id}/*",
    ]

    principals {
      identifiers = [local.service_account]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.name}-${local.account_id}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.name}-${local.account_id}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

# WAF Bucket Policy
data "aws_iam_policy_document" "waf_logs_s3" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::waf-logs-${var.name}-${local.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::waf-logs-${var.name}-${local.account_id}"]
  }
}

# S3 Bucket for WAF logs with fixed lifecycle configuration
module "waf_logs_s3" {
  source        = "boldlink/s3/aws"
  version       = "2.5.1"
  bucket        = "waf-logs-${var.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  bucket_policy = data.aws_iam_policy_document.waf_logs_s3.json
  
  # Fixed lifecycle configuration to avoid the warning
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
    Name = "waf-logs-${var.name}"
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
  name   = "firehose-waf-logs-policy-${var.name}"
  role   = aws_iam_role.firehose_waf_logs.id
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
    
    # These are the correct parameter names
    buffering_interval = 300
    buffering_size     = 5
  }
}

# CloudWatch Log Group for CloudFront WAF logs
resource "aws_cloudwatch_log_group" "waf_cloudfront_logs" {
  provider          = aws.cloudfront
  name              = "/aws/waf/cloudfront/${var.name}"
  retention_in_days = 30
  tags              = local.tags
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

  # Configure redacted fields
  logging_redacted_headers  = ["authorization", "x-api-key"] 
  logging_redact_method     = true
  
  # Additional redaction options
  logging_redacted_query_args   = ["token", "session_id"]
  logging_redact_body           = true
  logging_redact_uri_path       = false
  logging_redact_query_string   = false
  logging_redact_all_query_args = false
  
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

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}

module "waf_with_cloudfront" {
  providers = {
    aws = aws.cloudfront
  }
  source    = "./../.."
  name      = "${var.name}-cloudfront"
  scope     = var.scope
  
  # Enable logging with CloudWatch Log Group
  enable_logging          = true
  log_destination_configs = [aws_cloudwatch_log_group.waf_cloudfront_logs.arn]
  
  # Configure redacted fields for CloudFront
  logging_redacted_headers = ["cookie", "authorization"]
  logging_redact_method    = true
  logging_redact_uri_path  = true
  
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
}

variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "complete-waf-example"
}

variable "description" {
  type        = string
  description = "Friendly description of the WebACL."
  default     = "Example complete WAF ACL"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the created resources"
  default = {
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources"
  default     = "terraform-aws-waf"
}

variable "custom_header_name" {
  type        = string
  description = "The name of the custom header to insert"
  default     = "X-My-Company-Tracking-ID"
}

variable "custom_header_value" {
  type        = string
  description = "The value of the custom header to insert"
  default     = "1234567890"
}

variable "force_destroy" {
  type        = bool
  description = "Whether to force destroy of bucket"
  default     = true
}

variable "internal" {
  type        = bool
  description = "Whether the created ALB is internal or not"
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Whether to enable protection of ALB from deletion"
  default     = false
}

variable "access_logs_enabled" {
  type        = bool
  description = "Whether access logs are enabled for the ALB"
  default     = true
}

variable "http_ingress_rules" {
  type        = any
  description = "The configuration for ALB ingress rules"
  default = {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "http_egress_rules" {
  type        = any
  description = "The configuration for ALB egress rules"
  default = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "create_acl_association" {
  type        = bool
  description = "Whether to create WAF ACL association resource for ALB"
  default     = true
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether to enable cloudwatch metrics"
  default     = false
}

variable "sampled_requests_enabled" {
  type        = bool
  description = "Whether to enable simple requests"
  default     = false
}

# Cloudfront waf
variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. To work with CloudFront, you must also specify the region `us-east-1 (N. Virginia)` on the AWS provider."
  default     = "CLOUDFRONT"
}

# Local variables
locals {
  account_id      = data.aws_caller_identity.current.account_id
  service_account = data.aws_elb_service_account.main.arn
  tags            = merge(var.tags, { Name = var.name })
  vpc_id          = data.aws_vpc.supporting.id
  public_subnets  = [for s in data.aws_subnet.public : s.id]
}

terraform {
  required_version = ">= 0.14.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
      configuration_aliases = [aws.cloudfront]
    }
  }
}