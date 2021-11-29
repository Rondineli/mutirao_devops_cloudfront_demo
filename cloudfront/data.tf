data "aws_caller_identity" "account" {}

data "aws_canonical_user_id" "account" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
}

data "aws_availability_zones" "allzones" {}

data "aws_ami" "ec2" {
  most_recent      = true
  name_regex       = "amzn2-ami-hvm*"
  owners           = ["amazon"]
}
