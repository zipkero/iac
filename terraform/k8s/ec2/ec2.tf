resource "aws_iam_role" "ec2_role" {
  name = "${var.prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_role_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "control_instance" {
  count                = var.control_count
  ami                  = var.ami_id
  instance_type        = var.control_instance_type
  vpc_security_group_ids = [var.control_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  subnet_id            = var.subnet_ids[count.index % length(var.subnet_ids)]

  user_data = file("${path.module}/control-init.sh")

  tags = {
    Name = "${var.prefix}-control-instance-${count.index}"
    Role = "ControlPlane"
  }
}

resource "aws_instance" "worker_instance" {
  count                = var.worker_count
  ami                  = var.ami_id
  instance_type        = var.worker_instance_type
  vpc_security_group_ids = [var.worker_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  subnet_id            = var.subnet_ids[count.index % length(var.subnet_ids)]

  user_data = file("${path.module}/worker-init.sh")

  tags = {
    Name = "${var.prefix}-worker-instance-${count.index}"
    Role = "WorkerPlane"
  }
}