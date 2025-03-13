variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "nlb_sg_id" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "cidr_block" {
  type = string
}