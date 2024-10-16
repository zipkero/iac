variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "prefix" {
  type    = string
  default = "dev"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "${var.prefix}_vpc"
  }
}

data "aws_subnets" "dev_public_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.dev_vpc.id]
  }
  tags = {
    Type = "${var.prefix}_public_subnet"
  }
}

data "aws_subnet" "dev_public_subnet" {
  for_each = toset(data.aws_subnets.dev_public_subnets.ids)
  id = each.value
}

module "sg" {
  source = "./sg"

  prefix     = var.prefix
  vpc_id     = data.aws_vpc.dev_vpc.id
  cidr_block = var.cidr_block
}

module "ec2" {
  source = "./ec2"

  prefix = var.prefix

  public_subnet_ids = [for subnet in data.aws_subnet.dev_public_subnet : subnet.id]
  dev_sg_id         = module.sg.dev_sg_id
}