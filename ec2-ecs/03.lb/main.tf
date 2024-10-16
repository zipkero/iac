variable "region" {
  type    = string
  default = "ap-northeast-1"
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "test"
}

variable "certificate_id" {
  type    = string
  default = "arn:aws:acm:ap-northeast-2:296519485637:certificate/ad954597-f89b-4255-bcad-7299ea1ca481"
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

data "aws_subnets" "sample_public_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.sample_vpc.id]
  }
  tags = {
    Type = "sample_${var.prefix}_public_subnet"
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

data "aws_subnet" "sample_public_subnet" {
  for_each = toset(data.aws_subnets.sample_public_subnets.ids)
  id = each.value
}

data "aws_subnet" "sample_private_subnet" {
  for_each = toset(data.aws_subnets.sample_private_subnets.ids)
  id = each.value
}

module "sg" {
  source = "./sg"

  prefix = var.prefix
  vpc_id = data.aws_vpc.sample_vpc.id
}

module "lb" {
  source = "./lb"

  prefix            = var.prefix
  vpc_id            = data.aws_vpc.sample_vpc.id
  public_subnet_ids = [for subnet in data.aws_subnet.sample_public_subnet : subnet.id]
  alb_sg_id         = module.sg.alb_sg_id
  nlb_sg_id         = module.sg.nlb_sg_id

  certificate_id = var.certificate_id
  cidr_block    = data.aws_vpc.sample_vpc.cidr_block
}