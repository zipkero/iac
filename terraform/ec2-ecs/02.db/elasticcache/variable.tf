variable "prefix" {
  type = string
}

variable "redis_sg_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}