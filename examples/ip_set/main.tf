module "ipv4_set_example" {
  source         = "./../.."
  name           = "${var.name}-v4"
  tags           = merge({ "Name" = "${var.name}-v4" }, var.tags)
  default_action = var.default_action

  rules = [
    {
      name     = "${var.name}-ipv4-set"
      priority = 3

      action = {
        allow = {}
      }

      statement = {
        ip_set_reference_statement = {
          ip_set_forwarded_ip_config = {
            fallback_behaviorr = "MATCH"
            header_name        = "X-Forwarded-For"
            position           = "ANY"
          }
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-ipv4-metric"
        sampled_requests_enabled   = false
      }
    }
  ]

  ip_set_v4 = [
    {
      name        = var.name
      description = var.description
      scope       = var.scope
      addresses   = var.addresses
    }
  ]
}


module "ipv6_set_example" {
  source         = "./../.."
  name           = "${var.name}-v6"
  tags           = merge({ "Name" = "${var.name}-v6" }, var.tags)
  default_action = "block"

  rules = [
    {
      name     = "${var.name}-ipv6-set"
      priority = 3

      action = {
        allow = {}
      }

      statement = {
        ip_set_reference_statement = {
          ip_set_forwarded_ip_config = {
            fallback_behaviorr = "MATCH"
            header_name        = "X-Forwarded-For"
            position           = "ANY"
          }
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-ipv6-metric"
        sampled_requests_enabled   = false
      }
    }
  ]

  ip_set_v6 = [
    {
      name        = "allow-custom-ipv6"
      description = "deny custom ipv4"
      scope       = var.scope
      addresses   = ["2001:0db8:1234:0000:0000:0000:0000:0000/48"]
    }
  ]
}
