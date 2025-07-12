provider "aws" {
  region = "ap-northeast-2" # 서울 리전 사용
}

variable "prefix" {
  type    = string
  default = "k8s-dev"
}

module "vpc" {
  source = "./vpc"
  prefix = var.prefix
}