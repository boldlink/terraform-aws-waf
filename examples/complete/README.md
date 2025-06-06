[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-waf/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-waf.svg)](https://github.com/boldlink/terraform-aws-waf/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/module-examples-tests.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/auto-merge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# Terraform module example usage for association with Application load balancer


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |
| <a name="provider_aws.cloudfront"></a> [aws.cloudfront](#provider\_aws.cloudfront) | 5.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | boldlink/lb/aws | 1.0.8 |
| <a name="module_alb_access_logs_s3"></a> [alb\_access\_logs\_s3](#module\_alb\_access\_logs\_s3) | boldlink/s3/aws | 2.5.1 |
| <a name="module_waf_alb"></a> [waf\_alb](#module\_waf\_alb) | ./../.. | n/a |
| <a name="module_waf_cloudfront"></a> [waf\_cloudfront](#module\_waf\_cloudfront) | ./../.. | n/a |
| <a name="module_waf_logs_s3"></a> [waf\_logs\_s3](#module\_waf\_logs\_s3) | boldlink/s3/aws | 2.5.1 |
| <a name="module_waf_s3"></a> [waf\_s3](#module\_waf\_s3) | ./../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.firehose_cloudfront_waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose_cloudfront_waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.cloudfront_waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.alb_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.waf_logs_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.supporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | Whether access logs are enabled for the ALB | `bool` | `true` | no |
| <a name="input_create_acl_association"></a> [create\_acl\_association](#input\_create\_acl\_association) | Whether to create WAF ACL association resource for ALB | `bool` | `true` | no |
| <a name="input_custom_header_name"></a> [custom\_header\_name](#input\_custom\_header\_name) | The name of the custom header to insert | `string` | `"X-My-Company-Tracking-ID"` | no |
| <a name="input_custom_header_value"></a> [custom\_header\_value](#input\_custom\_header\_value) | The value of the custom header to insert | `string` | `"1234567890"` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Whether to enable protection of ALB from deletion | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to force destroy of bucket | `bool` | `true` | no |
| <a name="input_http_egress_rules"></a> [http\_egress\_rules](#input\_http\_egress\_rules) | The configuration for ALB egress rules | `any` | <pre>{<br>  "cidr_blocks": [<br>    "0.0.0.0/0"<br>  ],<br>  "from_port": 0,<br>  "protocol": "-1",<br>  "to_port": 0<br>}</pre> | no |
| <a name="input_http_ingress_rules"></a> [http\_ingress\_rules](#input\_http\_ingress\_rules) | The configuration for ALB ingress rules | `any` | <pre>{<br>  "cidr_blocks": [<br>    "0.0.0.0/0"<br>  ],<br>  "description": "allow http",<br>  "from_port": 80,<br>  "protocol": "tcp",<br>  "to_port": 80<br>}</pre> | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether the created ALB is internal or not | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Friendly name of the WebACL. | `string` | `"complete-waf-example"` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. To work with CloudFront, you must also specify the region `us-east-1 (N. Virginia)` on the AWS provider. | `string` | `"CLOUDFRONT"` | no |
| <a name="input_supporting_resources_name"></a> [supporting\_resources\_name](#input\_supporting\_resources\_name) | Name of the supporting resources | `string` | `"terraform-aws-waf"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the created resources | `map(string)` | <pre>{<br>  "Department": "DevOps",<br>  "Environment": "examples",<br>  "LayerId": "cExample",<br>  "LayerName": "cExample",<br>  "Owner": "Boldlink",<br>  "Project": "Examples",<br>  "user::CostCenter": "terraform-registry"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Third party software
This repository uses third party software:
* [pre-commit](https://pre-commit.com/) - Used to help ensure code and documentation consistency
  * Install with `brew install pre-commit`
  * Manually use with `pre-commit run`
* [terraform 0.14.11](https://releases.hashicorp.com/terraform/0.14.11/) For backwards compatibility we are using version 0.14.11 for testing making this the min version tested and without issues with terraform-docs.
* [terraform-docs](https://github.com/segmentio/terraform-docs) - Used to generate the [Inputs](#Inputs) and [Outputs](#Outputs) sections
  * Install with `brew install terraform-docs`
  * Manually use via pre-commit
* [tflint](https://github.com/terraform-linters/tflint) - Used to lint the Terraform code
  * Install with `brew install tflint`
  * Manually use via pre-commit

#### BOLDLink-SIG 2023
