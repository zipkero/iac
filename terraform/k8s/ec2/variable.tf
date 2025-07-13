variable "prefix" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "control_instance_type" {
  type = string
}

variable "worker_instance_type" {
  type = string
}

variable "control_sg_id" {
  type = string
}

variable "worker_sg_id" {
  type = string
}

variable "control_count" {
  type = number
}

variable "worker_count" {
  type = number
}