output "availability_zones" {
  value = [for subnet in aws_subnet.sample_db_subnet : subnet.availability_zone]
}

output "db_subnet_ids" {
  value = [for subnet in aws_subnet.sample_db_subnet : subnet.id]
}
