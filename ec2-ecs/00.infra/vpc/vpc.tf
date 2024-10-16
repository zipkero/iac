# VPC 생성
resource "aws_vpc" "sample_vpc" {
  cidr_block                       = var.cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "sample_${var.prefix}_vpc"
  }
}

# igw 생성
resource "aws_internet_gateway" "sample_igw" {
  vpc_id = aws_vpc.sample_vpc.id

  tags = {
    Name = "sample_${var.prefix}_igw"
  }
}

# nat 용 eip 생성
resource "aws_eip" "sample_eip" {
  for_each = {for subnet in var.private_subnet_config : subnet.name => subnet}
  domain   = "vpc"

  tags = {
    Name = "${each.key}_eip"
  }
}

# nat 생성
resource "aws_nat_gateway" "sample_nat" {
  for_each  = {for subnet in var.private_subnet_config : subnet.name => subnet}
  subnet_id = aws_subnet.sample_public_subnet[each.key].id

  allocation_id = aws_eip.sample_eip[each.key].id

  tags = {
    Name = "${each.key}_nat"
  }
}

# public subnet 생성
resource "aws_subnet" "sample_public_subnet" {
  for_each = {
    for idx, subnet in var.public_subnet_config : subnet.name => {
      idx  = idx
      name = subnet.name
      cidr = subnet.cidr
      az   = subnet.az
    }
  }

  vpc_id            = aws_vpc.sample_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  ipv6_cidr_block = cidrsubnet(aws_vpc.sample_vpc.ipv6_cidr_block, 8, each.value.idx)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "${each.value.name}_public_subnet"
    Type = "sample_${var.prefix}_public_subnet"
  }
}

# private subnet 생성
resource "aws_subnet" "sample_private_subnet" {
  for_each = {for subnet in var.private_subnet_config : subnet.name => subnet}

  vpc_id            = aws_vpc.sample_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}_private_subnet"
    Type = "sample_${var.prefix}_private_subnet"
  }
}

# public subnet route table 생성
resource "aws_route_table" "sample_public_rt" {
  vpc_id = aws_vpc.sample_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.sample_igw.id
  }

  tags = {
    Name = "sample_${var.prefix}_public_rt"
  }
}

# public subnet association
resource "aws_route_table_association" "sample_public_rt_association" {
  for_each = aws_subnet.sample_public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.sample_public_rt.id
}

# private subnet route table 생성
resource "aws_route_table" "sample_private_rt" {
  depends_on = [aws_nat_gateway.sample_nat]

  for_each = {for subnet in var.private_subnet_config : subnet.name => subnet}
  vpc_id   = aws_vpc.sample_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample_nat[each.key].id
  }

  tags = {
    Name = "${each.key}_private_rt"
  }
}

# private subnet association
resource "aws_route_table_association" "sample_private_rta" {
  for_each       = {for subnet in var.private_subnet_config : subnet.name => subnet}
  subnet_id      = aws_subnet.sample_private_subnet[each.key].id
  route_table_id = aws_route_table.sample_private_rt[each.key].id
}


