output "alb_tg_5503_arn" {
  value = aws_lb_target_group.sample_alb_tg_5503.arn
}

output "nlb_tg_5601_arn" {
  value = aws_lb_target_group.sample_nlb_tg_5601.arn
}


output "nlb_tg_5602_arn" {
  value = aws_lb_target_group.sample_nlb_tg_5602.arn
}

output "alb_dns_name" {
  value = aws_lb.sample_alb.dns_name
}

output "nlb_dns_name" {
  value = aws_lb.sample_nlb.dns_name
}