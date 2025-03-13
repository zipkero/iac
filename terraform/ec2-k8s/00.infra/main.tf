variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cidr_block" {
  type    = string
  default = "172.16.10.0/24"
}

variable "prefix" {
  type    = string
  default = "dev"
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
      name : "${var.prefix}-public",
      cidr : "172.16.10.0/24",
      az : "${var.region}a"
    }
  ]
}