terraform {
  backend "s3" {
    bucket = "sample-tf-state"
    key    = "prod/02.db/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

variable "region" {
  type    = string
  # default = "ap-northeast-2"
  default = "ap-northeast-1"
}

variable "cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "prod"
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

data "aws_instance" "sample_bastion" {
  filter {
    name   = "tag:Name"
    values = ["sample_${var.prefix}_bastion_instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

module "vpc" {
  source = "vpc"

  prefix = var.prefix
  vpc_id = data.aws_vpc.sample_vpc.id

  db_subnet_config = [
    {
      name : "sample_${var.prefix}-db-1",
      cidr : "172.16.100.0/24",
      az : "${var.region}a"
    },
    {
      name : "sample_${var.prefix}-db-2",
      cidr : "172.16.101.0/24",
      az : "${var.region}d"
    }
  ]
}

module "sg" {
  source = "sg"

  prefix = var.prefix

  vpc_id = data.aws_vpc.sample_vpc.id

  bastion_private_ip = data.aws_instance.sample_bastion.private_ip
}

module "rds" {
  source = "rds"

  prefix = var.prefix

  vpc_id = data.aws_vpc.sample_vpc.id

  availability_zones = module.vpc.availability_zones

  db_subnet_ids = module.vpc.db_subnet_ids
  mysql_sg_id   = module.sg.mysql_sg_id
}

module "elasticcache" {
  source = "elasticcache"

  prefix = var.prefix

  db_subnet_ids = module.vpc.db_subnet_ids
  redis_sg_id   = module.sg.redis_sg_id
}
