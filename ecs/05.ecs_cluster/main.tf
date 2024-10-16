terraform {
  backend "s3" {
    bucket = "sample-tf-state"
    key    = "prod/05.ecs_cluster/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

variable "region" {
  type    = string
  # default = "ap-northeast-2"
  default = "ap-northeast-1"
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

module "iam" {
  source = "./iam"

  prefix = var.prefix
}

module "sg" {
  source = "./sg"

  prefix = var.prefix

  vpc_id = data.aws_vpc.sample_vpc.id

  cidr_block = data.aws_vpc.sample_vpc.cidr_block

  private_cidr_blocks = [for subnet in data.aws_subnet.sample_private_subnet : subnet.cidr_block]
}

module "ec2" {
  source = "./ec2"

  prefix = var.prefix

  ecs_instance_profile_name = module.iam.ecs_instance_profile_name

  http_report_template_sg_id     = module.sg.http_report_template_sg_id
  http_game_template_sg_id       = module.sg.http_game_template_sg_id
  tcp_master_template_sg_id      = module.sg.tcp_master_template_sg_id
  tcp_social_template_sg_id      = module.sg.tcp_social_template_sg_id
  http_backoffice_template_sg_id = module.sg.http_backoffice_template_sg_id

}

module "ecs" {
  source = "./ecs"

  prefix = var.prefix

  vpc_id = data.aws_vpc.sample_vpc.id

  region = var.region

  private_subnet_ids = [for subnet in data.aws_subnet.sample_private_subnet : subnet.id]

  http_report_template_id     = module.ec2.http_report_template_id
  http_game_template_id       = module.ec2.http_game_template_id
  tcp_master_template_id      = module.ec2.tcp_master_template_id
  tcp_social_template_id      = module.ec2.tcp_social_template_id
  http_backoffice_template_id = module.ec2.http_backoffice_template_id
}