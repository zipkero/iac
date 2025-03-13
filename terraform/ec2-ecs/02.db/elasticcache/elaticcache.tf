resource "aws_elasticache_subnet_group" "sample_redis_subnet_group" {
  name       = "sample-${var.prefix}-redis-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_elasticache_replication_group" "sample_elasticache_replication_group" {
  replication_group_id = "sample-${var.prefix}-elasticache-rg"
  description          = "sample ${var.prefix} elasticache rg"
  engine               = "redis"
  engine_version       = "7.1"

  node_type                  = "cache.t4g.micro"
  num_node_groups            = 2
  replicas_per_node_group    = 1
  automatic_failover_enabled = true
  multi_az_enabled           = true
  parameter_group_name       = "default.redis7.cluster.on"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.sample_redis_subnet_group.name
  security_group_ids = [var.redis_sg_id]
}

