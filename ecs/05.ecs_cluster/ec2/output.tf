output "http_report_template_id" {
  value = aws_launch_template.sample_http_report_launch_template.id
}

output "http_game_template_id" {
  value = aws_launch_template.sample_http_game_launch_template.id
}

output "tcp_master_template_id" {
  value = aws_launch_template.sample_tcp_master_launch_template.id
}

output "tcp_social_template_id" {
  value = aws_launch_template.sample_tcp_social_launch_template.id
}

output "http_backoffice_template_id" {
  value = aws_launch_template.sample_http_backoffice_launch_template.id
}