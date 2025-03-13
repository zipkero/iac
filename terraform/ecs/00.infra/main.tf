terraform {
  backend "s3" {
    bucket = "sample-tf-state"
    key    = "prod/00.infra/terraform.tfstate"
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

module "vpc" {
  source = "vpc"

  prefix = var.prefix

  cidr_block = var.cidr_block

  public_subnet_config = [
    {
      name : "sample-${var.prefix}-1",
      cidr : "172.16.0.0/22",
      az : "${var.region}a"
    },
    {
      name : "sample-${var.prefix}-2",
      cidr : "172.16.4.0/22",
      az : "${var.region}d"
    }
  ]

  private_subnet_config = [
    {
      name : "sample-${var.prefix}-1",
      cidr : "172.16.8.0/22",
      az : "${var.region}a"
    },
    {
      name : "sample-${var.prefix}-2",
      cidr : "172.16.12.0/22",
      az : "${var.region}d"
    }
  ]
}

module "endpoint" {
  source = "endpoint"

  prefix = var.prefix

  vpc_id = module.vpc.vpc_id

  # s3_endpoint_service_name = "com.amazonaws.ap-northeast-2.s3"
  s3_endpoint_service_name      = "com.amazonaws.ap-northeast-1.s3"

  # ecr_api_endpoint_service_name = "com.amazonaws.ap-northeast-2.ecr.api"
  ecr_api_endpoint_service_name = "com.amazonaws.ap-northeast-1.ecr.api"

  # ecr_dkr_endpoint_service_name = "com.amazonaws.ap-northeast-2.ecr.dkr"
  ecr_dkr_endpoint_service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"

  # logs_endpoint_service_name = "com.amazonaws.ap-northeast-2.logs"
  logs_endpoint_service_name    = "com.amazonaws.ap-northeast-1.logs"

  # sts_endpoint_service_name = "com.amazonaws.ap-northeast-2.sts"
  sts_endpoint_service_name = "com.amazonaws.ap-northeast-1.sts"

  ecr_api_sg_id = module.sg.ecr_api_sg_id
  ecr_dkr_sg_id = module.sg.ecr_dkr_sg_id
  logs_sg_id    = module.sg.logs_sg_id
  sts_sg_id     = module.sg.sts_sg_id

  private_rt_ids     = module.vpc.private_rt_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "iam" {
  source = "iam"

  prefix = var.prefix
}

module "sg" {
  source = "sg"

  prefix = var.prefix

  vpc_id     = module.vpc.vpc_id
  cidr_block = var.cidr_block
}
