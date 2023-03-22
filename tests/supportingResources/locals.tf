locals {
  public_subnets = [cidrsubnet(var.cidr_block, 8, 1), cidrsubnet(var.cidr_block, 8, 2), cidrsubnet(var.cidr_block, 8, 3)]
  region         = data.aws_region.current.id
  account_id     = data.aws_caller_identity.current.id
  tags= merge({ "Name" = var.name }, var.tags)
}
