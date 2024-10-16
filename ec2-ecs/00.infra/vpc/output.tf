output "vpc_id" {
  value = aws_vpc.sample_vpc.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.sample_public_subnet : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.sample_private_subnet : subnet.id]
}

output "private_rt_ids" {
  value = [for rt in aws_route_table.sample_private_rt : rt.id]
}
