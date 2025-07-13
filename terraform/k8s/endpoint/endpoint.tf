resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  security_group_ids = [var.vpc_endpoint_sg]
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"

  tags = {
    Name = "${var.prefix}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = var.vpc_id
  security_group_ids = [var.vpc_endpoint_sg]
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssmmessages"

  tags = {
    Name = "${var.prefix}-ssm-message-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = var.vpc_id
  security_group_ids = [var.vpc_endpoint_sg]
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ec2messages"

  tags = {
    Name = "${var.prefix}-ec2-messagess-endpoint"
  }
}