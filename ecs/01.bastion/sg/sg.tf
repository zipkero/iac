# bastion sg
resource "aws_security_group" "sample_bastion_sg" {
  name   = "sample_${var.prefix}_bastion_sg"
  vpc_id = var.vpc_id

  /* 포트포워딩으로 인해 22번 포트는 사용하지 않음
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["111.111.111.111/32", "${var.build_public_ip}/32"]
  }
  */

  ingress {
    from_port = 10201
    to_port   = 10201
    protocol  = "tcp"
    cidr_blocks = ["111.111.111.111/32", "${var.build_public_ip}/32"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["111.111.111.111/32", "${var.build_public_ip}/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample_${var.prefix}_bastion_sg"
  }
}