resource "aws_ecs_task_definition" "sample_tcp_social_task_definition" {
  family       = "sample_${var.prefix}_tcp_social_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 3000
  memory       = 7000

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sample_${var.prefix}_tcp_social"
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
          awslogs-stream-prefix = "sample_${var.prefix}_tcp_social"
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
          value = "false"
        },
        {
          name  = "ENABLE_SOCIAL_SERVER",
          value = "true"
        },
        {
          name  = "PORT"
          value = "5602"
        }
      ]
      portMappings = [
        {
          containerPort = 5602
          hostPort      = 5602
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "sample_tcp_social_service" {
  name            = "sample_${var.prefix}_tcp_social_service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sample_tcp_social_task_definition.arn
  desired_count   = 2

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = var.nlb_tg_5602_arn
    container_name   = "sample_${var.prefix}_tcp_social"
    container_port   = 5602
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ServiceName == sample_${var.prefix}_tcp_social"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    security_groups = [var.tcp_social_service_sg_id]
    subnets = var.private_subnet_ids
  }
}

resource "aws_security_group_rule" "sample_tcp_social_health_check_sg_rule" {
  type                     = "ingress"
  from_port                = 5602
  to_port                  = 5602
  protocol                 = "tcp"
  security_group_id        = var.tcp_social_service_sg_id
  source_security_group_id = var.nlb_sg_id
}