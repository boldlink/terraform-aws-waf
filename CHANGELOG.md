# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: CKV_AWS_192 #"Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"
- fix: CKV2_AWS_31 #"Ensure WAF2 has a Logging Configuration"
- feat: Add remaining statement features for the rule block
- feat: add remaining features in managed_rule_group_statement block
- feat: Add more examples on different usage of the module showcasing the usage of most dynamic blocks
- feat: Add classic waf submodule and examples
- feat: Add rule group features
- feat: Add regex pattern set features
- feat: Add web acl logging configuration feature(s)
- fix: CKV_TF_1 #"Ensure Terraform module sources use a commit hash"
- fix: CKV_AWS_342 #"Ensure WAF rule has any actions"

## [1.1.0] - 2025-04-30
 - feat: adding the byte match statement support
 - feat: adding the logging configuration support
 - feat: adding the new rules and logging configuration examples

## [1.0.3] - 2023-11-08
 - Added an example showcasing Global scope(cloudfront)
 - fix: default action block
 - added an example with default action == block
 - added an example with rule labels
 - added an ipv6 set example
 - added custom response body example
 - added an example rule with a custom response
 - added an example rule with a managed group rule statement
 - added module outputs

## [1.0.2] - 2023-08-17
- fix: vpc version used in supporting resources
- fix: added checkov exceptions to `.checkov.yaml` file

## [1.0.1] - 2023-05-04
- fix: Modified README.md text on the version of resources created

## [1.0.0] - 2023-03-21
- feat: Added required waf acl features
- feat: Added web acl association resource
- feat: Added IP set feature

[Unreleased]: https://github.com/boldlink/terraform-aws-waf/compare/1.0.3...HEAD

[1.0.3]: https://github.com/boldlink/terraform-aws-waf/releases/tag/1.0.3
[1.0.2]: https://github.com/boldlink/terraform-aws-waf/releases/tag/1.0.2
[1.0.1]: https://github.com/boldlink/terraform-aws-waf/releases/tag/1.0.1
[1.0.0]: https://github.com/boldlink/terraform-aws-waf/releases/tag/1.0.0
