# logs endpoint sg
resource "aws_security_group" "sample_logs_sg" {
  name   = "sample_${var.prefix}_logs_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_logs_sg"
  }
}

# ecr endpoint sg
resource "aws_security_group" "sample_ecr_api_sg" {
  name   = "sample_${var.prefix}_ecr_api_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_ecr_api_sg"
  }
}

# ecr docker sg
resource "aws_security_group" "sample_ecr_dkr_sg" {
  name   = "sample_${var.prefix}_ecr_dkr_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_ecr_dkr_sg"
  }
}

# ecr docker sg
resource "aws_security_group" "sample_sts_sg" {
  name   = "sample_${var.prefix}_sts_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_sts_sg"
  }
}

