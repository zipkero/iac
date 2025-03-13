variable "prefix" {
  type = string
}

variable "ssh_keys" {
  type    = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}