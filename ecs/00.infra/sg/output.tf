output "ecr_api_sg_id" {
  value = aws_security_group.sample_ecr_api_sg.id
}

output "ecr_dkr_sg_id" {
  value = aws_security_group.sample_ecr_dkr_sg.id
}

output "logs_sg_id" {
  value = aws_security_group.sample_logs_sg.id
}

output "sts_sg_id" {
  value = aws_security_group.sample_sts_sg.id
}