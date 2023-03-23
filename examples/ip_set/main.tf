module "ip_set_example" {
  source = "./../.."
  name   = var.name
  tags   = local.tags

  rules = [
    {
      name     = var.rule_name
      priority = 5

      action = {
        allow = {}
      }

      # Specify empty `statement` block when using ip_set block
      statement = {}

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-metric"
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
