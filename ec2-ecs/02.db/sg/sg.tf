resource "aws_security_group" "sample_rds_sg" {
  name   = "sample_${var.prefix}_rds_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["43.202.145.69/32", "172.16.8.0/22", "172.16.12.0/22", "${var.bastion_private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_rds_sg"
  }
}

resource "aws_security_group" "sample_redis_sg" {
  name   = "sample_${var.prefix}_redis_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["43.202.145.69/32", "172.16.8.0/22", "172.16.12.0/22", "${var.bastion_private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_redis_sg"
  }
}