# vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  for_each = {
    for idx, subnet in var.public_subnet_config : tostring(idx) => {
      idx  = idx
      name = subnet.name
      cidr = subnet.cidr
      az   = subnet.az
    }
  }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.prefix}-${each.value.name}"
  }
}

# public rt
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# eip
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnet

  domain = "vpc"
  tags = {
    Name = "${var.prefix}-nat-eip-${each.key}"
  }
}

# nat
resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public_subnet

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id

  tags = {
    Name = "${var.prefix}-nat"
  }
}

# private subnet
resource "aws_subnet" "private_subnet" {
  for_each = {
    for idx, subnet in var.private_subnet_config : tostring(idx) => subnet
  }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.prefix}-${each.value.name}"
  }
}

# private rt
resource "aws_route_table" "private_rt" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${var.prefix}-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

