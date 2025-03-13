variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_log_group_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "web_repo_url" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "http_game_service_sg_id" {
  type = string
}

variable "alb_tg_5503_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "cluster_id" {
  type = string
}