resource "aws_ecs_task_definition" "sample_http_report_task_definition" {
  family       = "sample_${var.prefix}_http_report_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 600
  memory       = 600

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sample_${var.prefix}_http_report"
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
          awslogs-stream-prefix = "sample_${var.prefix}_http_report"
        }
      }
      environment = [
        {
          name  = "ENABLE_GAME_SERVER",
          value = "false"
        },
        {
          name  = "ENABLE_REPORT_SERVER",
          value = "true"
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
          value = "5502"
        }
      ]
      portMappings = [
        {
          containerPort = 5502
          hostPort      = 5502
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "sample_http_report_service" {
  name            = "sample_${var.prefix}_http_report_service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sample_http_report_task_definition.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  load_balancer {
    target_group_arn = var.alb_tg_5502_arn
    container_name   = "sample_${var.prefix}_http_report"
    container_port   = 5502
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ServiceName == sample_${var.prefix}_http_report"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    security_groups = [var.http_report_service_sg_id]
    subnets = var.private_subnet_ids
  }
}

resource "aws_security_group_rule" "sample_http_report_health_check_sg_rule" {
  type                     = "ingress"
  from_port                = 5502
  to_port                  = 5502
  protocol                 = "tcp"
  security_group_id        = var.http_report_service_sg_id
  source_security_group_id = var.alb_sg_id
}