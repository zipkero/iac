# VPC 생성
resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}_vpc"
  }
}

# igw 생성
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.prefix}_igw"
  }
}

# public subnet 생성
resource "aws_subnet" "dev_public_subnet" {
  for_each = {for subnet in var.public_subnet_config : subnet.name => subnet}

  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}_public_subnet"
    Type = "${var.prefix}_public_subnet"
  }
}

resource "aws_route_table" "dev_public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "${var.prefix}_public_rt"
  }
}

# public subnet association
resource "aws_route_table_association" "dev_public_rt_association" {
  for_each = aws_subnet.dev_public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.dev_public_rt.id
}