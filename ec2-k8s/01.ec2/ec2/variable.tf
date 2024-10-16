variable "prefix" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "dev_sg_id" {
  type = string
}