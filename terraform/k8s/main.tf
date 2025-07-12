provider "aws" {
  region = "ap-northeast-2" # 서울 리전 사용
}

# vpc
resource "aws_vpc" "zipkero_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "zipkero-vpc"
  }
}

# igw
resource "aws_internet_gateway" "zipkero_igw" {
  vpc_id = aws_vpc.zipkero_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# public subnet
resource "aws_subnet" "zipkero_public_subnet" {
  vpc_id            = aws_vpc.zipkero_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "my-public-subnet"
  }
}

# public rt
resource "aws_route_table" "zipkero_public_rt" {
  vpc_id = aws_vpc.zipkero_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zipkero_igw.id
  }

  tags = {
    Name = "zipkero-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.zipkero_public_subnet.id
  route_table_id = aws_route_table.zipkero_public_rt.id
}

# eip
resource "aws_eip" "zipkero_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "zipkero-nat-eip"
  }
}

# nat
resource "aws_nat_gateway" "zipkero_nat" {
  allocation_id = aws_eip.zipkero_nat_eip.id
  subnet_id     = aws_subnet.zipkero_public_subnet.id

  tags = {
    Name = "zipkero-nat"
  }
}

# private subnet
resource "aws_subnet" "zipkero_private_subnet" {
  vpc_id            = aws_vpc.zipkero_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "zipkero-private-subnet"
  }
}

# private rt
resource "aws_route_table" "zipkero_private_rt" {
  vpc_id = aws_vpc.zipkero_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.zipkero_nat.id
  }

  tags = {
    Name = "zipkero-private-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.zipkero_private_subnet.id
  route_table_id = aws_route_table.zipkero_private_rt.id
}

