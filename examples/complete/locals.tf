locals {
  account_id      = data.aws_caller_identity.current.account_id
  service_account = data.aws_elb_service_account.main.arn
  tags            = merge(var.tags, { Name = var.name })
  vpc_id          = data.aws_vpc.supporting.id
  public_subnets  = [for s in data.aws_subnet.public : s.id]
}