# 서브넷 생성
resource "aws_subnet" "sample_subnet_1" {
  vpc_id            = data.aws_vpc.sample_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "sample_subnet_1"
  }
}

# 라우트 테이블 및 라우트 생성
resource "aws_route_table" "sample_rt" {
  vpc_id = data.aws_vpc.sample_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.sample_igw.id
  }

  tags = {
    Name = "sample_rt"
  }
}

# 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "sample_rta_subnet_1" {
  subnet_id      = aws_subnet.sample_subnet_1.id
  route_table_id = aws_route_table.sample_rt.id
}