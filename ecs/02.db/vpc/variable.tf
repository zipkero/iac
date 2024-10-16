variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_config" {
  type = list(object(
    {
      name = string
      cidr = string
      az   = string
    }))
}