variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "mysql_sg_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}