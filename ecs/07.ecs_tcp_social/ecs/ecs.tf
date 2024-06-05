resource "aws_ecs_task_definition" "sample_tcp_social_task_definition" {
  family       = "sample_${var.prefix}_tcp_social_task_definition"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu          = 1024
  memory       = 1024

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
  desired_count   = 1

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

resource "aws_appautoscaling_target" "sample_tcp_social_ast" {
  # max_capacity       = 5
  max_capacity = 1
  # min_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.cluster_id}/sample_${var.prefix}_tcp_social_service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = var.ecs_autoscale_role_arn
}

resource "aws_appautoscaling_policy" "sample_tcp_social_ast_policy_scale_up" {
  name               = "sample_${var.prefix}_tcp_social_ast_policy_scale_up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sample_tcp_social_ast.resource_id
  scalable_dimension = aws_appautoscaling_target.sample_tcp_social_ast.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sample_tcp_social_ast.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 90.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "sample_tcp_social_ast_policy_scale_down" {
  name               = "sample_${var.prefix}_tcp_social_ast_policy_scale_down"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sample_tcp_social_ast.resource_id
  scalable_dimension = aws_appautoscaling_target.sample_tcp_social_ast.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sample_tcp_social_ast.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
