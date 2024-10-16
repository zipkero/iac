resource "aws_ecs_task_definition" "sample_http_game_task_definition" {
  family       = "sample_${var.prefix}_http_game_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 3000
  memory       = 7000

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sample_${var.prefix}_http_game"
      image                  = var.web_repo_url
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
          awslogs-stream-prefix = "sample_${var.prefix}_http_game"
        }
      }
      environment = [
        {
          name  = "ENABLE_GAME_SERVER",
          value = "true"
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
          value = "false"
        },
        {
          name  = "PORT"
          value = "5503"
        }
      ]
      portMappings = [
        {
          containerPort = 5503
          hostPort      = 5503
        }
      ],
    }
  ])
}

resource "aws_ecs_service" "sample_http_game_service" {
  name            = "sample_${var.prefix}_http_game_service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sample_http_game_task_definition.arn
  desired_count   = 2

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = var.alb_tg_5503_arn
    container_name   = "sample_${var.prefix}_http_game"
    container_port   = 5503
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ServiceName == sample_${var.prefix}_http_game"
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
    security_groups = [var.http_game_service_sg_id]
    subnets = var.private_subnet_ids
  }
}

resource "aws_security_group_rule" "sample_http_game_health_check_sg_rule" {
  type                     = "ingress"
  from_port                = 5503
  to_port                  = 5503
  protocol                 = "tcp"
  security_group_id        = var.http_game_service_sg_id
  source_security_group_id = var.alb_sg_id
}

