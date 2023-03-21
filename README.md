[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-waf/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-waf.svg)](https://github.com/boldlink/terraform-aws-waf/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# AWS WAF Terraform module

## Description

This terraform module creates WAF resources on AWS.

## Reasons to use this Module
This module has the following features;
- Creates both classic WAF and WAFv2 resources
- Ability to create WAF ACLs
- Specify both IPv4 and IPv6 Ipsets
- Simple to use with easy to understand examples
- Adheres to AWS best security practices by using checkov to scan for security loopholes

Examples available [`here`](./examples)

## Usage
**NOTE**: These examples use the latest version of this module

```hcl
module "miniumum" {
  source = "boldlink/waf/aws"
  name   = "minimum-example-waf-acl"
  scope  = "REGIONAL"
}
```
## Documentation

[Amazon WAF Documentation](https://docs.aws.amazon.com/waf/latest/developerguide/how-aws-waf-works.html)

[Terraform WAF module documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl)

[Terraform WAF classic module documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_rule)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.ipset_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.ipset_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether to enable cloudwatch metrics | `bool` | `false` | no |
| <a name="input_custom_response_body"></a> [custom\_response\_body](#input\_custom\_response\_body) | Defines custom response bodies that can be referenced by `custom_response` actions | `any` | `[]` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | COnfiguration block for action to take when no actions are specified | `any` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Friendly description of the WebACL. | `string` | `null` | no |
| <a name="input_ip_set_reference_statement"></a> [ip\_set\_reference\_statement](#input\_ip\_set\_reference\_statement) | A rule statement used to detect web requests coming from particular IP addresses or address ranges. | `any` | `{}` | no |
| <a name="input_ip_set_v4"></a> [ip\_set\_v4](#input\_ip\_set\_v4) | IPV4 IP set | `any` | `[]` | no |
| <a name="input_ip_set_v6"></a> [ip\_set\_v6](#input\_ip\_set\_v6) | IPV6 IP set | `any` | `[]` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | The name of the metric | `string` | `"sample-name-1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Friendly name of the WebACL. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | Rule blocks used to identify the web requests that you want to `allow`, `block`, or `count` | `any` | `[]` | no |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | Whether to enable sample requests | `bool` | `false` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. To work with CloudFront, you must also specify the region `us-east-1 (N. Virginia)` on the AWS provider. | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of key-value pairs to associate with the resource. | `map(string)` | `{}` | no |
| <a name="input_web_acl_resource_arn"></a> [web\_acl\_resource\_arn](#input\_web\_acl\_resource\_arn) | The Amazon Resource Name (ARN) of the resource to associate with the web ACL. This must be an ARN of an Application Load Balancer, an Amazon API Gateway stage, or an Amazon Cognito User Pool. | `string` | `null` | no |

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

### Supporting resources:

The example stacks are used by BOLDLink developers to validate the modules by building an actual stack on AWS.

Some of the modules have dependencies on other modules (ex. Ec2 instance depends on the VPC module) so we create them
first and use data sources on the examples to use the stacks.

Any supporting resources will be available on the `tests/supportingResources` and the lifecycle is managed by the `Makefile` targets.

Resources on the `tests/supportingResources` folder are not intended for demo or actual implementation purposes, and can be used for reference.

### Makefile
The makefile contained in this repo is optimized for linux paths and the main purpose is to execute testing for now.
* Create all tests stacks including any supporting resources:
```console
make tests
```
* Clean all tests *except* existing supporting resources:
```console
make clean
```
* Clean supporting resources - this is done separately so you can test your module build/modify/destroy independently.
```console
make cleansupporting
```
* !!!DANGER!!! Clean the state files from examples and test/supportingResources - use with CAUTION!!!
```console
make cleanstatefiles
```


#### BOLDLink-SIG 2023
