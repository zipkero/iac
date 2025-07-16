provider "aws" {
  region = "ap-northeast-2" # 서울 리전 사용
}

variable "prefix" {
  type    = string
  default = "k8s-dev"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_config" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "public-subnet-01"
      cidr = "10.0.0.0/24"
      az   = "ap-northeast-2a"
    },
  ]
}

variable "private_subnet_config" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "private-subnet-01"
      cidr = "10.0.100.0/24"
      az   = "ap-northeast-2a"
    },
  ]
}

module "vpc" {
  source = "./vpc"

  prefix                = var.prefix
  vpc_cidr              = var.vpc_cidr
  public_subnet_config  = var.public_subnet_config
  private_subnet_config = var.private_subnet_config
}

module "sg" {
  source = "./sg"

  prefix   = var.prefix
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "endpoint" {
  source = "./endpoint"

  prefix          = var.prefix
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  vpc_endpoint_sg = module.sg.vpc_endpoint_sg_id
  subnet_ids      = module.vpc.private_subnet_ids
}

module "ec2" {
  source = "./ec2"

  prefix                = var.prefix
  subnet_ids            = module.vpc.private_subnet_ids
  ami_id                = "ami-0ff0bbc5968fcbc61"
  control_instance_type = "t4g.small"
  worker_instance_type  = "t4g.small"
  control_sg_id         = module.sg.control_sg_id
  worker_sg_id          = module.sg.worker_sg_id
  control_count         = 1
  worker_count          = 2
}