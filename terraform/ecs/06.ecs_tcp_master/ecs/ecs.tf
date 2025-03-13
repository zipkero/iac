resource "aws_service_discovery_private_dns_namespace" "sample_private_dns_namespace" {
  name        = "sample.${var.prefix}.local"
  description = "sample private dns namespace"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "sample_discovery_tcp_master_service" {
  name         = "tcp-master"
  namespace_id = aws_service_discovery_private_dns_namespace.sample_private_dns_namespace.id
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.sample_private_dns_namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_task_definition" "sample_tcp_master_task_definition" {
  family       = "sample_${var.prefix}_tcp_master_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 3000
  memory       = 7000

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sample_${var.prefix}_tcp_master"
      image                  = var.tcp_repo_url
      essential              = true
      enable_execute_command = true
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.ecs_log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "sample_${var.prefix}_tcp_master"
        }
      }
      environment = [
        {
          name  = "ENABLE_GAME_SERVER",
          value = "false"
        },
        {
          name  = "ENABLE_REPORT_SERVER",
          value = "false"
        },
        {
          name  = "ENABLE_SOCIAL_MASTER_SERVER",
          value = "true"
        },
        {
          name  = "ENABLE_SOCIAL_SERVER",
          value = "false"
        },
        {
          name  = "PORT"
          value = "5601"
        }
      ]
      portMappings = [
        {
          containerPort = 5601
          hostPort      = 5601
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "sample_tcp_master_service" {
  depends_on = [
    aws_service_discovery_service.sample_discovery_tcp_master_service,
  ]

  name            = "sample_${var.prefix}_tcp_master_service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sample_tcp_master_task_definition.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = var.nlb_tg_5601_arn
    container_name   = "sample_${var.prefix}_tcp_master"
    container_port   = 5601
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sample_discovery_tcp_master_service.arn
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ServiceName == sample_${var.prefix}_tcp_master"
  }

  network_configuration {
    security_groups = [var.tcp_master_service_sg_id]
    subnets = var.private_subnet_ids
  }
}

resource "aws_security_group_rule" "sample_tcp_master_health_check_sg_rule" {
  type                     = "ingress"
  from_port                = 5601
  to_port                  = 5601
  protocol                 = "tcp"
  security_group_id        = var.tcp_master_service_sg_id
  source_security_group_id = var.nlb_sg_id
}
