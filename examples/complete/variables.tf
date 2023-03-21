variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "complete-example-waf"
}

variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application"
  default     = "REGIONAL"
}

variable "rule_1_name" {
  type        = string
  description = "Name of the rule"
  default     = "allow-ke-traffic"
}
