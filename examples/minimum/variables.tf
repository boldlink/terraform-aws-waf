variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "minimum-example-waf-acl"
}

variable "scope" {
  type        = string
  description = "Whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`"
  default     = "REGIONAL"
}
