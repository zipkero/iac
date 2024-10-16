variable "prefix" {
  type = string
}
variable "cidr_block" {
  type = string
}

variable "public_subnet_config" {
  type = list(object(
    {
      name = string
      cidr = string
      az   = string
    }))
}