resource "aws_ecs_task_definition" "sample_http_backoffice_task_definition" {
  family       = "sample_${var.prefix}_http_backoffice_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 1500
  memory       = 1500

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sample_${var.prefix}_http_backoffice"
      image                  = var.backoffice_repo_url
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
          awslogs-stream-prefix = "sample_${var.prefix}_http_backoffice"
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
          name  = "ASPNETCORE_ENVIRONMENT",
          value = "Production"
        },
        {
          name  = "PORT"
          value = "5600"
        }
      ]
      portMappings = [
        {
          containerPort = 5600
          hostPort      = 5600
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "sample_${var.prefix}_http_backoffice"
          containerPath = "/app/sample.backoffice/Keys"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name      = "sample_${var.prefix}_http_backoffice"
    host_path = "/usr/local/sample/keys"
  }
}

resource "aws_ecs_service" "sample_http_backoffice_service" {
  name            = "sample_${var.prefix}_http_backoffice_service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sample_http_backoffice_task_definition.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = var.alb_tg_5600_arn
    container_name   = "sample_${var.prefix}_http_backoffice"
    container_port   = 5600
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ServiceName == sample_${var.prefix}_http_backoffice"
  }

  network_configuration {
    security_groups = [var.http_backoffice_service_sg_id]
    subnets = var.private_subnet_ids
  }
}

resource "aws_security_group_rule" "sample_http_backoffice_health_check_sg_rule" {
  type                     = "ingress"
  from_port                = 5600
  to_port                  = 5600
  protocol                 = "tcp"
  security_group_id        = var.http_backoffice_service_sg_id
  source_security_group_id = var.alb_sg_id
}