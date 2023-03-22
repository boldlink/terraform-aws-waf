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
  type        = any
  description = "COnfiguration block for action to take when no actions are specified"
  default     = {}
}

variable "custom_response_body" {
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
