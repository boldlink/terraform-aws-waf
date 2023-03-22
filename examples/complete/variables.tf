variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "complete-waf-example"
}

variable "rule_name" {
  type        = string
  description = "Name of the rule"
  default     = "allow-alb-regional-traffic"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the created resources"
  default = {
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}

variable "supporting_resources_name" {
  type        = string
  description = "Name of the supporting resources"
  default     = "terraform-aws-waf"
}
