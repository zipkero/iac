output "alb_sg_id" {
  value = aws_security_group.sample_alb_sg.id
}

output "nlb_sg_id" {
  value = aws_security_group.sample_nlb_sg.id
}