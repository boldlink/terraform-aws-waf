[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-waf/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-waf.svg)](https://github.com/boldlink/terraform-aws-waf/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/module-examples-tests.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-waf/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-waf/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# Terraform module example of complete and most common configuration


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.55.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ip_set_example"></a> [ip\_set\_example](#module\_ip\_set\_example) | ./../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addresses"></a> [addresses](#input\_addresses) | An array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. | `list(any)` | <pre>[<br>  "53.115.27.20/32"<br>]</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Description of IP set | `string` | `"allow-custom-ip"` | no |
| <a name="input_name"></a> [name](#input\_name) | Friendly name of the WebACL. | `string` | `"ip-set-example"` | no |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | Name of the rule | `string` | `"allow-custom-ip"` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. | `string` | `"REGIONAL"` | no |
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
