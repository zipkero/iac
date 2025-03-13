# private subnet 에 위치한 ecs 가 s3 에 접근하기 위한 endpoint 설정
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = var.s3_endpoint_service_name
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_rt_ids

  tags = {
    Name = "sample_${var.prefix}_s3_endpoint"
  }
}

# private subnet 에 위치한 ecs 가 logs 에 접근하기 위한 endpoint 설정
resource "aws_vpc_endpoint" "logs_endpoint" {
  # depends_on = [aws_subnet.sample_private_subnet]

  vpc_id              = var.vpc_id
  service_name        = var.logs_endpoint_service_name
  subnet_ids          = var.private_subnet_ids
  vpc_endpoint_type   = "Interface"
  security_group_ids = [var.logs_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "sample_${var.prefix}_logs_endpoint"
  }
}

# private subnet 에 위치한 ecs 가 ecr 에 접근하기 위한 endpoint 설정
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  # depends_on = [aws_subnet.sample_private_subnet]

  vpc_id              = var.vpc_id
  service_name        = var.ecr_api_endpoint_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids = [var.ecr_api_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "sample_${var.prefix}_ecr_api_endpoint"
  }
}

# private subnet 에 위치한 ecs 가 ecr 에 접근하기 위한 endpoint 설정
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  # depends_on = [aws_subnet.sample_private_subnet]

  vpc_id              = var.vpc_id
  service_name        = var.ecr_dkr_endpoint_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids = [var.ecr_dkr_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "sample_${var.prefix}_ecr_dkr_endpoint"
  }
}

# private subnet 에 위치한 ecs 가 sts 에 접근하기 위한 endpoint 설정
resource "aws_vpc_endpoint" "sts_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = var.sts_endpoint_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids = [var.sts_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "sample_${var.prefix}_sts_endpoint"
  }
}