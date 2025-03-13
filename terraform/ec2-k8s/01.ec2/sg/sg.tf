# ec2-k8s sg
resource "aws_security_group" "dev_ec2_sg" {
  name   = "${var.prefix}_ec2_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 10201
    to_port     = 10201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}_ec2_sg"
  }
}