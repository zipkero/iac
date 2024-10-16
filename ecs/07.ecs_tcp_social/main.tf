terraform {
  backend "s3" {
    bucket = "sample-tf-state"
    key    = "prod/07.ecs_tcp_social/terraform.tfstate"
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

data "aws_lb" "sample_alb" {
  name = "sample-${var.prefix}-alb"
}

data "aws_lb" "sample_nlb" {
  name = "sample-${var.prefix}-nlb"
}

data "aws_lb_target_group" "sample_alb_tg_5502" {
  name = "sample-${var.prefix}-alb-tg-5502"
}

data "aws_lb_target_group" "sample_alb_tg_5503" {
  name = "sample-${var.prefix}-alb-tg-5503"
}

data "aws_lb_target_group" "sample_alb_tg_5600" {
  name = "sample-${var.prefix}-alb-tg-5600"
}

data "aws_lb_target_group" "sample_nlb_tg_5601" {
  name = "sample-${var.prefix}-nlb-tg-5601"
}

data "aws_lb_target_group" "sample_nlb_tg_5602" {
  name = "sample-${var.prefix}-nlb-tg-5602"
}

data "aws_security_group" "sample_alb_sg" {
  name = "sample_${var.prefix}_alb_sg"
}

data "aws_security_group" "sample_nlb_sg" {
  name = "sample_${var.prefix}_nlb_sg"
}

data "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "sample_${var.prefix}_ecs_instance_profile"
}

data "aws_security_group" "sample_http_report_template_sg" {
  name = "sample_${var.prefix}_http_report_template_sg"
}

data "aws_security_group" "sample_http_game_template_sg" {
  name = "sample_${var.prefix}_http_game_template_sg"
}

data "aws_security_group" "sample_tcp_master_template_sg" {
  name = "sample_${var.prefix}_tcp_master_template_sg"
}

data "aws_security_group" "sample_tcp_social_template_sg" {
  name = "sample_${var.prefix}_tcp_social_template_sg"
}

data "aws_security_group" "sample_http_backoffice_template_sg" {
  name = "sample_${var.prefix}_http_backoffice_template_sg"
}

data "aws_iam_role" "sample_ecs_task_execution_role" {
  name = "sample_${var.prefix}_ecs_task_execution_role"
}

data "aws_iam_role" "ecs_task_role_arn" {
  name = "sample_${var.prefix}_ecs_task_role"
}

data "aws_ecs_cluster" "sample_ecs_cluster" {
  cluster_name = "sample_${var.prefix}_ecs_cluster"
}

data "aws_cloudwatch_log_group" "sample_ecs_log_group" {
  name = "/sample-${var.prefix}-ecs"
}

data "aws_iam_role" "sample_ecs_autoscale_role" {
  name = "sample_${var.prefix}_ecs_autoscale_role"
}

module "ecs" {
  source = "./ecs"

  prefix = var.prefix

  vpc_id = data.aws_vpc.sample_vpc.id

  region = var.region

  ecs_log_group_name = data.aws_cloudwatch_log_group.sample_ecs_log_group.name

  private_subnet_ids = [for subnet in data.aws_subnet.sample_private_subnet : subnet.id]

  alb_sg_id = data.aws_security_group.sample_alb_sg.id
  nlb_sg_id = data.aws_security_group.sample_nlb_sg.id

  http_report_service_sg_id     = data.aws_security_group.sample_http_report_template_sg.id
  http_game_service_sg_id       = data.aws_security_group.sample_http_game_template_sg.id
  tcp_master_service_sg_id      = data.aws_security_group.sample_tcp_master_template_sg.id
  tcp_social_service_sg_id      = data.aws_security_group.sample_tcp_social_template_sg.id
  http_backoffice_service_sg_id = data.aws_security_group.sample_http_backoffice_template_sg.id

  alb_tg_5502_arn = data.aws_lb_target_group.sample_alb_tg_5502.arn
  alb_tg_5503_arn = data.aws_lb_target_group.sample_alb_tg_5503.arn
  alb_tg_5600_arn = data.aws_lb_target_group.sample_alb_tg_5600.arn
  nlb_tg_5601_arn = data.aws_lb_target_group.sample_nlb_tg_5601.arn
  nlb_tg_5602_arn = data.aws_lb_target_group.sample_nlb_tg_5602.arn

  web_repo_url        = ""
  tcp_repo_url        = ""
  backoffice_repo_url = ""

  cluster_id   = data.aws_ecs_cluster.sample_ecs_cluster.id
  cluster_name = data.aws_ecs_cluster.sample_ecs_cluster.cluster_name

  ecs_task_execution_role_arn = data.aws_iam_role.sample_ecs_task_execution_role.arn
  ecs_task_role_arn           = data.aws_iam_role.ecs_task_role_arn.arn
  ecs_autoscale_role_arn      = data.aws_iam_role.sample_ecs_autoscale_role.arn
}