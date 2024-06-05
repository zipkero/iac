output "mysql_sg_id" {
  value = aws_security_group.sample_rds_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.sample_redis_sg.id
}