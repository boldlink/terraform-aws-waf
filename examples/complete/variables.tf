variable "name" {
  type        = string
  description = "Friendly name of the WebACL."
  default     = "complete-waf-example"
}

variable "description" {
  type        = string
  description = "Friendly description of the WebACL."
  default     = "Example complete WAF ACL"
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

variable "custom_header_name" {
  type        = string
  description = "The name of the custom header to insert"
  default     = "X-My-Company-Tracking-ID"
}

variable "custom_header_value" {
  type        = string
  description = "The value of the custom header to insert"
  default     = "1234567890"
}

variable "force_destroy" {
  type        = bool
  description = "Whether to force destroy of bucket"
  default     = true
}

variable "internal" {
  type        = bool
  description = "Whether the created ALB is internal or not"
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Whether to enable protection of ALB from deletion"
  default     = false
}

variable "access_logs_enabled" {
  type        = bool
  description = "Whether access logs are enabled for the ALB"
  default     = true
}

variable "http_ingress_rules" {
  type        = any
  description = "The configuration for ALB ingress rules"
  default = {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "http_egress_rules" {
  type        = any
  description = "The configuration for ALB egress rules"
  default = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "create_acl_association" {
  type        = bool
  description = "Whether to create WAF ACL association resource for ALB"
  default     = true
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether to enable cloudwatch metrics"
  default     = false
}

variable "sampled_requests_enabled" {
  type        = bool
  description = "Whether to enable simple requests"
  default     = false
}

# Cloudfront waf
variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are `CLOUDFRONT` or `REGIONAL`. To work with CloudFront, you must also specify the region `us-east-1 (N. Virginia)` on the AWS provider."
  default     = "CLOUDFRONT"
}
