output "http_report_template_sg_id" {
  value = aws_security_group.sample_http_report_template_sg.id
}

output "http_game_template_sg_id" {
  value = aws_security_group.sample_http_game_template_sg.id
}

output "tcp_master_template_sg_id" {
  value = aws_security_group.sample_tcp_master_template_sg.id
}

output "tcp_social_template_sg_id" {
  value = aws_security_group.sample_tcp_social_template_sg.id
}

output "http_backoffice_template_sg_id" {
  value = aws_security_group.sample_http_backoffice_template_sg.id
}