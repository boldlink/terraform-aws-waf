resource "aws_wafv2_web_acl" "main" {
  name        = var.name
  description = var.description
  scope       = var.scope
  tags        = var.tags

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_bodies
    content {
      key          = custom_response_body.value.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = var.metric_name
    sampled_requests_enabled   = var.sampled_requests_enabled
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = try([rule.value.action], [])
        content {

          dynamic "allow" {
            for_each = try([action.value.allow], [])
            content {
              dynamic "custom_request_handling" {
                for_each = try([allow.value.custom_request_handling], [])
                content {
                  dynamic "insert_header" {
                    for_each = try([custom_request_handling.value.insert_header], [])
                    content {
                      name  = try(insert_header.value.name, null)
                      value = try(insert_header.value.value, null)
                    }
                  }
                }
              }
            }
          }

          dynamic "block" {
            for_each = try([action.value.block], [])
            content {
              dynamic "custom_response" {
                for_each = try([block.value.custom_response], [])
                content {
                  custom_response_body_key = try(custom_response.value.custom_response_body_key, null)
                  response_code            = custom_response.value.response_code

                  dynamic "response_header" {
                    for_each = try(custom_response.value.response_header, [])
                    content {
                      name  = try(response_header.value.name, null)
                      value = try(response_header.value.value, null)
                    }
                  }
                }
              }
            }
          }

          dynamic "captcha" {
            for_each = try([action.value.captcha], [])
            content {
              dynamic "custom_request_handling" {
                for_each = try([captcha.value.custom_request_handling], [])
                content {
                  dynamic "insert_header" {
                    for_each = try([custom_request_handling.value.insert_header], [])
                    content {
                      name  = try(insert_header.value.name, null)
                      value = try(insert_header.value.value, null)
                    }
                  }
                }
              }
            }
          }

          dynamic "challenge" {
            for_each = try([action.value.challenge], [])
            content {
              dynamic "custom_request_handling" {
                for_each = try([challenge.value.custom_request_handling], [])
                content {
                  dynamic "insert_header" {
                    for_each = try([custom_request_handling.value.insert_header], [])
                    content {
                      name  = try(insert_header.value.name, null)
                      value = try(insert_header.value.value, null)
                    }
                  }
                }
              }
            }
          }

          dynamic "count" {
            for_each = try([action.value.count], [])
            content {
              dynamic "custom_request_handling" {
                for_each = try([count.value.custom_request_handling], [])
                content {
                  dynamic "insert_header" {
                    for_each = try([custom_request_handling.value.insert_header], [])
                    content {
                      name  = try(insert_header.value.name, null)
                      value = try(insert_header.value.value, null)
                    }
                  }
                }
              }
            }
          }

        }
      }

      ## This block only applies to rules with `rule_group_reference_statement` or `managed_rule_group_statement` blocks
      dynamic "override_action" {
        for_each = try([rule.value.override_action], [])
        content {
          dynamic "count" {
            for_each = try([override_action.value.count], [])
            content {}
          }

          dynamic "none" {
            for_each = try([override_action.value.none], [])
            content {}
          }
        }
      }

      dynamic "rule_label" {
        for_each = try(rule.value.rule_label, [])
        content {
          name = rule_label.value
        }
      }

      dynamic "statement" {
        for_each = try([rule.value.statement], [])
        content {

          dynamic "geo_match_statement" {
            for_each = try([statement.value.geo_match_statement], [])
            content {
              country_codes = geo_match_statement.value.country_codes

              dynamic "forwarded_ip_config" {
                for_each = try([geo_match_statement.value.forwarded_ip_config], [])
                content {
                  fallback_behavior = forwarded_ip_config.value.fallback_behavior
                  header_name       = forwarded_ip_config.value.header_name
                }
              }
            }
          }

          dynamic "ip_set_reference_statement" {
            for_each = length(var.ip_set_v4) > 0 ? [var.ip_set_reference_statement] : []
            content {
              arn = aws_wafv2_ip_set.ipset_v4[0].arn

              dynamic "ip_set_forwarded_ip_config" {
                for_each = try([ip_set_reference_statement.value.ip_set_forwarded_ip_config], [])
                content {
                  fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                  header_name       = ip_set_forwarded_ip_config.value.header_name
                  position          = ip_set_forwarded_ip_config.value.position
                }
              }
            }
          }

          dynamic "ip_set_reference_statement" {
            for_each = length(var.ip_set_v6) > 0 ? [var.ip_set_reference_statement] : []
            content {
              arn = aws_wafv2_ip_set.ipset_v6[0].arn

              dynamic "ip_set_forwarded_ip_config" {
                for_each = try([ip_set_reference_statement.value.ip_set_forwarded_ip_config], [])
                content {
                  fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                  header_name       = ip_set_forwarded_ip_config.value.header_name
                  position          = ip_set_forwarded_ip_config.value.position
                }
              }
            }
          }

          dynamic "managed_rule_group_statement" {
            for_each = try([statement.value.managed_rule_group_statement], [])
            content {
              name        = managed_rule_group_statement.value.name
              vendor_name = managed_rule_group_statement.value.vendor_name
              version     = try(managed_rule_group_statement.value.version, null)
            }
          }
          
          # byte_match_statement support
          dynamic "byte_match_statement" {
            for_each = try([statement.value.byte_match_statement], [])
            content {
              search_string         = byte_match_statement.value.search_string
              positional_constraint = byte_match_statement.value.positional_constraint

              # field_to_match block
              dynamic "field_to_match" {
                for_each = try([byte_match_statement.value.field_to_match], [])
                content {
                  # single_header field match
                  dynamic "single_header" {
                    for_each = try([field_to_match.value.single_header], [])
                    content {
                      name = single_header.value.name
                    }
                  }
                  
                  # method field match
                  dynamic "method" {
                    for_each = try([field_to_match.value.method], [])
                    content {}
                  }
                  
                  # uri_path field match
                  dynamic "uri_path" {
                    for_each = try([field_to_match.value.uri_path], [])
                    content {}
                  }
                  
                  # query_string field match
                  dynamic "query_string" {
                    for_each = try([field_to_match.value.query_string], [])
                    content {}
                  }
                  
                  # body field match
                  dynamic "body" {
                    for_each = try([field_to_match.value.body], [])
                    content {}
                  }
                  
                  # all_query_arguments field match
                  dynamic "all_query_arguments" {
                    for_each = try([field_to_match.value.all_query_arguments], [])
                    content {}
                  }
                }
              }
              
              # text_transformation block(s)
              dynamic "text_transformation" {
                for_each = try(byte_match_statement.value.text_transformation, [])
                content {
                  priority = text_transformation.value.priority
                  type     = text_transformation.value.type
                }
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = try([rule.value.visibility_config], [])
        content {
          cloudwatch_metrics_enabled = visibility_config.value.cloudwatch_metrics_enabled
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = visibility_config.value.sampled_requests_enabled
        }
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  count        = var.create_acl_association ? 1 : 0
  resource_arn = var.web_acl_resource_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  depends_on   = [aws_wafv2_web_acl.main]
}

resource "aws_wafv2_ip_set" "ipset_v4" {
  count              = length(var.ip_set_v4) > 0 ? length(var.ip_set_v4) : 0
  name               = var.ip_set_v4[count.index]["name"]
  description        = try(var.ip_set_v4[count.index]["description"], null)
  scope              = var.ip_set_v4[count.index]["scope"]
  ip_address_version = "IPV4"
  addresses          = try(var.ip_set_v4[count.index]["addresses"], null)
  tags               = var.tags
}

resource "aws_wafv2_ip_set" "ipset_v6" {
  count              = length(var.ip_set_v6) > 0 ? length(var.ip_set_v6) : 0
  name               = var.ip_set_v6[count.index]["name"]
  description        = try(var.ip_set_v6[count.index]["description"], null)
  scope              = var.ip_set_v6[count.index]["scope"]
  ip_address_version = "IPV6"
  addresses          = try(var.ip_set_v6[count.index]["addresses"], null)
  tags               = var.tags
}

# Logging configuration with static redacted_fields - Fixed structure
# Logging configuration with correct redacted_fields structure
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count                   = var.enable_logging ? 1 : 0
  log_destination_configs = var.log_destination_configs
  resource_arn            = aws_wafv2_web_acl.main.arn

  # Header redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redacted_headers != null ? var.logging_redacted_headers : []
    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }
  
  # Query argument redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redacted_query_args != null ? var.logging_redacted_query_args : []
    content {
      single_query_argument {
        name = redacted_fields.value
      }
    }
  }
  
  # All query arguments redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redact_all_query_args ? [1] : []
    content {
      all_query_arguments {}
    }
  }
  
  # Body redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redact_body ? [1] : []
    content {
      body {}
    }
  }
  
  # Method redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redact_method ? [1] : []
    content {
      method {}
    }
  }
  
  # URI path redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redact_uri_path ? [1] : []
    content {
      uri_path {}
    }
  }
  
  # Query string redaction
  dynamic "redacted_fields" {
    for_each = var.logging_redact_query_string ? [1] : []
    content {
      query_string {}
    }
  }

  # Logging filter configuration
  dynamic "logging_filter" {
    for_each = var.logging_filter != null ? [var.logging_filter] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = lookup(logging_filter.value, "filters", [])
        content {
          behavior = filter.value.behavior
          
          dynamic "condition" {
            for_each = lookup(filter.value, "conditions", [])
            content {
              dynamic "action_condition" {
                for_each = lookup(condition.value, "action_condition", null) != null ? [condition.value.action_condition] : []
                content {
                  action = action_condition.value
                }
              }

              dynamic "label_name_condition" {
                for_each = lookup(condition.value, "label_name_condition", null) != null ? [condition.value.label_name_condition] : []
                content {
                  label_name = label_name_condition.value
                }
              }
            }
          }
          
          requirement = filter.value.requirement
        }
      }
    }
  }

  depends_on = [aws_wafv2_web_acl.main]
}

# Output definitions
output "arn" {
  description = "The ARN of the WAF WebACL."
  value       = aws_wafv2_web_acl.main.arn
}

output "capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL."
  value       = aws_wafv2_web_acl.main.capacity
}

output "id" {
  description = "The ID of the WAF WebACL."
  value       = aws_wafv2_web_acl.main.id
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_web_acl.main.tags_all
}

output "ipv4_set_id" {
  description = "A unique identifier for the IPv4 set."
  value       = try(aws_wafv2_ip_set.ipset_v4[0].id, null)
}

output "ipv4_set_arn" {
  description = "The Amazon Resource Name (ARN) of the IPv4 set."
  value       = try(aws_wafv2_ip_set.ipset_v4[0].arn, null)
}

output "ipv6_set_id" {
  description = "A unique identifier for the IPv6 set."
  value       = try(aws_wafv2_ip_set.ipset_v6[0].id, null)
}

output "ipv6_set_arn" {
  description = "The Amazon Resource Name (ARN) of the IPv6 set."
  value       = try(aws_wafv2_ip_set.ipset_v6[0].arn, null)
}

output "log_destination_configs" {
  description = "The logging destination configuration for the WebACL."
  value       = try(aws_wafv2_web_acl_logging_configuration.main[0].log_destination_configs, null)
}

# Variable definitions
variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
}

variable "description" {
  type        = string
  description = "Friendly description of the WebACL."
  default     = null
}

variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. To work with CloudFront, you must also specify the region `us-east-1 (N. Virginia)` on the AWS provider."
  default     = "REGIONAL"
}

variable "default_action" {
  type        = string
  description = "Set to `allow` for WAF to allow requests by default. Set to `block` for WAF to block requests by default."
  default     = "allow"
}

variable "custom_response_bodies" {
  type        = any
  description = "Defines custom response bodies that can be referenced by `custom_response` actions"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Map of key-value pairs to associate with the resource."
  default     = {}
}

variable "rules" {
  type        = any
  description = "Rule blocks used to identify the web requests that you want to `allow`, `block`, or `count`"
  default     = []
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether to enable cloudwatch metrics"
  default     = false
}

variable "metric_name" {
  type        = string
  description = "The name of the metric"
  default     = "sample-name-1"
}

variable "sampled_requests_enabled" {
  type        = bool
  description = "Whether to enable sample requests"
  default     = false
}

variable "web_acl_resource_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the resource to associate with the web ACL. This must be an ARN of an Application Load Balancer, an Amazon API Gateway stage, or an Amazon Cognito User Pool."
  default     = null
}

variable "create_acl_association" {
  type        = bool
  description = "Whether to create acl association"
  default     = false
}

variable "ip_set_v4" {
  type        = any
  description = "IPV4 IP set"
  default     = []
}

variable "ip_set_v6" {
  type        = any
  description = "IPV6 IP set"
  default     = []
}

variable "ip_set_reference_statement" {
  type        = any
  description = "A rule statement used to detect web requests coming from particular IP addresses or address ranges."
  default     = {}
}

variable "enable_logging" {
  type        = bool
  description = "Whether to enable logging for the WAF WebACL"
  default     = false
}

variable "log_destination_configs" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose, CloudWatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
  default     = []
}

# Redacted fields variables with logging_ prefix for clarity
variable "logging_redacted_headers" {
  type        = list(string)
  description = "List of header names to redact in WAF logs"
  default     = null
}

variable "logging_redacted_query_args" {
  type        = list(string)
  description = "List of query argument names to redact in WAF logs"
  default     = null
}

variable "logging_redact_all_query_args" {
  type        = bool
  description = "Whether to redact all query arguments in WAF logs"
  default     = false
}

variable "logging_redact_body" {
  type        = bool
  description = "Whether to redact the request body in WAF logs"
  default     = false
}

variable "logging_redact_method" {
  type        = bool
  description = "Whether to redact the request method in WAF logs"
  default     = false
}

variable "logging_redact_uri_path" {
  type        = bool
  description = "Whether to redact the request URI path in WAF logs"
  default     = false
}

variable "logging_redact_query_string" {
  type        = bool
  description = "Whether to redact the query string in WAF logs"
  default     = false
}

variable "logging_filter" {
  type = object({
    default_behavior = string, # Required: "KEEP" or "DROP"
    filters = list(object({
      behavior = string, # Required: "KEEP" or "DROP"
      requirement = string, # Required: "MEETS_ALL" or "MEETS_ANY"
      conditions = list(object({
        action_condition = optional(string), # One of "ALLOW", "BLOCK", "COUNT", "CAPTCHA", "CHALLENGE"
        label_name_condition = optional(string) # The name of the label
      }))
    }))
  })
  description = "Configuration for WAF logging filters. Determines which requests are logged."
  default     = null
  
  validation {
    condition = var.logging_filter == null ? true : contains(["KEEP", "DROP"], var.logging_filter.default_behavior)
    error_message = "default_behavior must be either \"KEEP\" or \"DROP\"."
  }
}

terraform {
  required_version = ">= 0.14.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
  }
}