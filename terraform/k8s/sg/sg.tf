resource "aws_security_group" "ec2_control_sg" {
  name   = "${var.prefix}-ec2-control-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # icmp
  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kubernetes API
  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # etcd
  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kubelet API
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # kube-scheduler
  ingress {
    from_port = 10259
    to_port   = 10259
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # kube-controller-manager
  ingress {
    from_port = 10257
    to_port   = 10257
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # nodeport
  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_worker_sg" {
  name   = "${var.prefix}-ec2-worker-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kubelet API
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    security_groups = [aws_security_group.ec2_control_sg.id]
  }

  # nodeport
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "${var.prefix}-vpc-endpoint-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-vpc-endpoint-sg"
  }
}