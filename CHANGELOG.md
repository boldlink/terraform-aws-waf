# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: CKV_AWS_192 #"Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"
- fix: CKV2_AWS_31 #"Ensure WAF2 has a Logging Configuration"
- feat: Add remaining statement features for the rule block
- feat: Add an example showcasing Global scope(cloudfront)
- feat: Add more examples on different usage of the module showcasing the usage of most dynamic blocks
- feat: Add classic waf submodule and examples
- feat: Add rule group features
- feat: Add regex pattern set features
- feat: Add web acl logging configuration feature(s)

## [1.0.1] - 2023-05-04
- fix: Modified README.md text on the version of resources created

## [1.0.0] - 2023-03-21
- feat: Added required waf acl features
- feat: Added web acl association resource
- feat: Added IP set feature

[Unreleased]: https://github.com/boldlink/terraform-aws-waf/compare/1.0.0...HEAD
[1.0.0]: https://github.com/boldlink/terraform-aws-waf/releases/tag/1.0.0
