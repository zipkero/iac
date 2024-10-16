resource "aws_db_subnet_group" "sample_mysql_subnet_group" {
  name       = "sample_${var.prefix}_mysql_subnet_group"
  subnet_ids = var.db_subnet_ids
}

// Account 클러스터 생성
resource "aws_rds_cluster" "sample_rds_account_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-account-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 15
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_account_cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.sample_rds_account_cluster.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.sample_rds_account_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_account_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-account-cluster-instance-${count.index}"
  }
}

// 게임 001 클러스터 생성

resource "aws_rds_cluster" "sample_rds_game001_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-game001-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 15
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-game001-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_game001_cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.sample_rds_game001_cluster.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.sample_rds_game001_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_game001_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-cluster-instance-${count.index}"
  }
}

// 게임 002 클러스터 생성
resource "aws_rds_cluster" "sample_rds_game002_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-game002-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 15
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-game002-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_game002_cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.sample_rds_game002_cluster.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.sample_rds_game002_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_game002_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-game002-cluster-instance-${count.index}"
  }
}

// 게임 003 클러스터 생성
resource "aws_rds_cluster" "sample_rds_game003_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-game003-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 15
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-game003-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_game003_cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.sample_rds_game003_cluster.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.sample_rds_game003_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_game003_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-game003-cluster-instance-${count.index}"
  }
}

// 게임 004 클러스터 생성
resource "aws_rds_cluster" "sample_rds_game004_cluster" {
  cluster_identifier = "sample-${var.prefix}-rds-game004-cluster"
  availability_zones = var.availability_zones

  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.05.2"
  database_name   = "Account"
  master_username = "Server"
  master_password = "Richsample1234!*"

  # 기본 포트 사용
  port = "3306"

  # 백업 기본 1일
  backup_retention_period = 15
  skip_final_snapshot     = true

  vpc_security_group_ids = [var.mysql_sg_id]
  db_subnet_group_name = aws_db_subnet_group.sample_mysql_subnet_group.name

  tags = {
    Name = "sample-${var.prefix}-rds-game004-cluster"
  }
}

resource "aws_rds_cluster_instance" "sample_rds_game004_cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.sample_rds_game004_cluster.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.sample_rds_game004_cluster.engine
  engine_version     = aws_rds_cluster.sample_rds_game004_cluster.engine_version

  tags = {
    Name = "sample-${var.prefix}-rds-game004-cluster-instance-${count.index}"
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