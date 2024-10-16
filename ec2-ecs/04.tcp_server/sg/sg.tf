# tcp server sg
resource "aws_security_group" "sample_tcp_server_sg" {
  name   = "sample_${var.prefix}_tcp_server_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port   = 2375
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = var.private_cidr_blocks
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [var.cidr_block, "125.131.148.210/32", "43.202.145.69/32"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [var.cidr_block, "43.202.145.69/32"]
  }

  ingress {
    from_port = 5601
    to_port   = 5601
    protocol  = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port = 5602
    to_port   = 5602
    protocol  = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_tcp_server_sg"
  }
}