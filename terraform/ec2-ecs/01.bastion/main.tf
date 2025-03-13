variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "build_public_ip" {
  type    = string
  default = "43.202.145.69"
}

variable "ssh_keys" {
  description = "SSH public keys"
  type        = list(string)
  default     = [
  ]
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "test"
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
    name   = "vpc-id"
    values = [data.aws_vpc.sample_vpc.id]
  }
  tags = {
    Type = "sample_${var.prefix}_public_subnet"
  }
}

data "aws_subnet" "sample_public_subnet" {
  for_each = toset(data.aws_subnets.sample_public_subnets.ids)
  id       = each.value
}

module "sg" {
  source = "sg"

  prefix           = var.prefix
  vpc_id           = data.aws_vpc.sample_vpc.id
  build_public_ip  = var.build_public_ip
}

module "ec2" {
  source = "ec2"

  prefix = var.prefix

  ssh_keys = var.ssh_keys

  public_subnet_ids = [for subnet in data.aws_subnet.sample_public_subnet : subnet.id]
  bastion_sg_id     = module.sg.bastion_sg_id
}