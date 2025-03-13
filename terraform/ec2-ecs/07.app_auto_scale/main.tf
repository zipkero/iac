variable "region" {
  type    = string
  # default = "ap-northeast-2"
  default = "ap-northeast-1"
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "test"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_ecs_cluster" "sample_ecs_cluster" {
  cluster_name = "sample_${var.prefix}_ecs_cluster"
}

data "aws_iam_role" "sample_ecs_autoscale_role" {
  name = "sample_${var.prefix}_ecs_autoscale_role"
}

resource "aws_appautoscaling_target" "sample_http_game_ast" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${data.aws_ecs_cluster.sample_ecs_cluster.cluster_name}/sample_${var.prefix}_http_game_service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "sample_http_game_ast_tracking_policy" {
  name               = "sample_${var.prefix}_http_game_ast_tracking_policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sample_http_game_ast.resource_id
  scalable_dimension = aws_appautoscaling_target.sample_http_game_ast.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sample_http_game_ast.service_namespace

  depends_on = [
    aws_appautoscaling_target.sample_http_game_ast
  ]

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}