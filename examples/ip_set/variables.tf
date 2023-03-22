variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "ip-set-example"
}

variable "rule_name" {
  type        = string
  description = "Name of the rule"
  default     = "allow-custom-ip"
}

variable "description" {
  type        = string
  description = "Description of IP set"
  default     = "allow-custom-ip"
}

variable "addresses" {
  type        = list(any)
  description = "An array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation."
  default     = ["53.115.27.20/32"]
}

variable "scope" {
  type        = string
  description = "Whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`."
  default     = "REGIONAL"
}

variable "tags"{
type=map(string)
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
