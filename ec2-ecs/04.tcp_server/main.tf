variable "region" {
  type = string
  # default = "ap-northeast-2"
  default = "ap-northeast-1"
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "test"
}

variable "cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "ssh_keys" {
  description = "SSH public keys"
  type = list(string)
  default = [
  ]
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_vpc" "sample_vpc" {
  tags = {
    Name = "sample_${var.prefix}_vpc"
  }
}

data "aws_subnets" "sample_private_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.sample_vpc.id]
  }
  tags = {
    Type = "sample_${var.prefix}_private_subnet"
  }
}

data "aws_subnet" "sample_private_subnet" {
  for_each = toset(data.aws_subnets.sample_private_subnets.ids)
  id = each.value
}

data "aws_security_group" "sample_nlb_sg" {
  name = "sample_${var.prefix}_nlb_sg"
}

data "aws_lb_target_group" "sample_nlb_tg_5601" {
  name = "sample-${var.prefix}-nlb-tg-5601"
}

data "aws_lb_target_group" "sample_nlb_tg_5602" {
  name = "sample-${var.prefix}-nlb-tg-5602"
}

module "sg" {
  source = "./sg"

  prefix              = var.prefix
  vpc_id              = data.aws_vpc.sample_vpc.id
  cidr_block          = data.aws_vpc.sample_vpc.cidr_block
  private_cidr_blocks = [for subnet in data.aws_subnet.sample_private_subnet : subnet.cidr_block]
}

module "ec2" {
  source = "./ec2"

  prefix             = var.prefix
  vpc_id             = data.aws_vpc.sample_vpc.id
  ssh_keys           = var.ssh_keys
  tcp_server_sg_id   = module.sg.tcp_server_sg_id
  private_subnet_ids = [for subnet in data.aws_subnet.sample_private_subnet : subnet.id]
  nlb_tg_5601_arn    = data.aws_lb_target_group.sample_nlb_tg_5601.arn
  nlb_tg_5602_arn    = data.aws_lb_target_group.sample_nlb_tg_5602.arn
}