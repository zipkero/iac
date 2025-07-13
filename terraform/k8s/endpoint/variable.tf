variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_endpoint_sg" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}