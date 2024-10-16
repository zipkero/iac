output "vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.dev_public_subnet : subnet.id]
}