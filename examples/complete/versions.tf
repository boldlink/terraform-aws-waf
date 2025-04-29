provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.14.11"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.55.0"
      configuration_aliases = [aws.cloudfront]
    }
  }
}
