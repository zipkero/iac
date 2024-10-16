resource "aws_db_subnet_group" "sample_mysql_subnet_group" {
  name       = "sample_${var.prefix}_mysql_subnet_group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_rds_cluster" "sample_rds_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 1
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_cluster_instance" {
  count              = 2
  cluster_identifier = aws_rds_cluster.sample_rds_cluster.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.sample_rds_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-cluster-instance-${count.index}"
  }
}

# TODO: 읽기전용 엔드포인트 필요여부 확인
/*
resource "aws_rds_cluster_endpoint" "sample_rds_cluster_endpoint" {
  cluster_identifier          = aws_rds_cluster.sample_rds_cluster.id
  cluster_endpoint_identifier = "reader"
  custom_endpoint_type        = "READER"
  excluded_members            = aws_rds_cluster_instance.sample_rds_cluster_instance[*].id
  tags = {
    Name = "sample-${var.prefix}-rds-cluster-endpoint"
  }
}
*/