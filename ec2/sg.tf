# 보안그룹 생성
resource "aws_security_group" "sample_sg" {
  name        = "sample_sg"
  vpc_id      = data.aws_vpc.sample_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 5502
    to_port     = 5502
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 5503
    to_port     = 5503
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 5600
    to_port     = 5600
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }
  
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 5602
    to_port     = 5602
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_sg"
  }
}