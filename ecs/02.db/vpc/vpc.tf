resource "aws_subnet" "sample_db_subnet" {
  for_each = {for subnet in var.db_subnet_config : subnet.name => subnet}

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}_db_subnet"
    Type = "sample_${var.prefix}_db_subnet"
  }
}



