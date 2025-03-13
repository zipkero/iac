variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "private_cidr_blocks" {
  type = list(string)
}