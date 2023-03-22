resource "aws_wafv2_web_acl" "main" {
  name        = var.name
  description = var.description
  scope       = var.scope
  tags        = var.tags

  dynamic "default_action" {
    for_each = length(keys(var.default_action)) > 0 ? [] : [true]
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = length(keys(var.default_action)) > 0 ? [var.default_action] : []
    content {

      dynamic "allow" {
        for_each = try([default_action.value.allow], [])
        content {
          dynamic "custom_request_handling" {
            for_each = try([allow.value.custom_request_handling], [])
            content {

              dynamic "insert_header" {
                for_each = lookup(custom_request_handling.value, "insert_headers", [])
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
        for_each = try([default_action.value.block], [])
        content {

          dynamic "custom_response" {
            for_each = try([block.value.custom_response], [])
            content {
              custom_response_body_key = try(custom_response.value.custom_response_body_key, null)
              response_code            = custom_response.value.response_code

              dynamic "response_header" {
                for_each = try([custom_response.value.response_header], [])
                content {
                  name  = try(response_header.value.name, null)
                  value = try(response_header.value.value, null)
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_body
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
                    for_each = try([custom_response.value.response_header], [])
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
            content {
            }
          }

          dynamic "none" {
            for_each = try([override_action.value.none], [])
            content {
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = try([rule.value.rule_label], [])
        content {
          name = try(rule_label.value.name, null)
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
