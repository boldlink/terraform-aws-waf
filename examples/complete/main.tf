module "complete_example" {
  source = "./../.."
  name   = var.name
  scope  = var.scope

  rules = [
    {
      name     = var.rule_1_name
      priority = 5

      action = {
        allow = {}
      }

      statement = {
        geo_match_statement = {
          country_codes = ["KE"]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "${var.name}-metric"
        sampled_requests_enabled   = false
      }
    }
  ]
}
