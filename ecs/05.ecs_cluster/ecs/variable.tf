variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "http_report_template_id" {
  type = string
}

variable "http_game_template_id" {
  type = string
}

variable "tcp_master_template_id" {
  type = string
}

variable "tcp_social_template_id" {
  type = string
}

variable "http_backoffice_template_id" {
  type = string
}