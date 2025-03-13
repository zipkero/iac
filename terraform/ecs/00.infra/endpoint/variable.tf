variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "s3_endpoint_service_name" {
  type = string
}

variable "ecr_api_endpoint_service_name" {
  type = string
}

variable "ecr_dkr_endpoint_service_name" {
  type = string
}

variable "logs_endpoint_service_name" {
  type = string
}

variable "sts_endpoint_service_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_rt_ids" {
  type = list(string)
}

variable "logs_sg_id" {
  type = string
}

variable "ecr_api_sg_id" {
  type = string
}

variable "ecr_dkr_sg_id" {
  type = string
}

variable "sts_sg_id" {
  type = string
}