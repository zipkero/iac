output "control_sg_id" {
  value = aws_security_group.ec2_control_sg.id
}

output "worker_sg_id" {
  value = aws_security_group.ec2_worker_sg.id
}

output "vpc_endpoint_sg_id" {
  value = aws_security_group.vpc_endpoint_sg.id
}