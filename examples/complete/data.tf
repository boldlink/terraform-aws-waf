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
data "aws_iam_policy_document" "alb_s3" {
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
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.name}-${local.account_id}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
  statement {
    actions   = ["s3:GetBucketAcl"]
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
    resources = ["arn:aws:s3:::aws-waf-logs-${var.name}-${local.account_id}/*"]
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
    resources = ["arn:aws:s3:::aws-waf-logs-${var.name}-${local.account_id}"]
  }
}