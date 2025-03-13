variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "tcp_server_sg_id" {
  type = string
}

variable "nlb_tg_5601_arn" {
  type = string
}

variable "nlb_tg_5602_arn" {
  type = string
}