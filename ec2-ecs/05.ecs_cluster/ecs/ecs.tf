resource "aws_cloudwatch_log_group" "sample_ecs_log_group" {
  name = "/sample-${var.prefix}-ecs"
}

resource "aws_ecs_cluster" "sample_ecs_cluster" {
  name = "sample_${var.prefix}_ecs_cluster"

  tags = {
    Name = "sample_${var.prefix}_ecs_cluster"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "sample_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.sample_ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.sample_http_game_ecs_capacity_providers.name,
  ]
}

resource "aws_autoscaling_group" "sample_http_game_asg" {
  name                      = "sample_${var.prefix}_http_game_asg"
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies = ["OldestInstance"]
  launch_template {
    id      = var.http_game_template_id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "sample_${var.prefix}_http_game_asg"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "sample_http_game_ecs_capacity_providers" {
  name = "sample_${var.prefix}_http_game_ecs_capacity_providers"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.sample_http_game_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 50
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      instance_warmup_period    = 300
    }
  }

  tags = {
    Name = "sample_${var.prefix}_http_game_ecs_capacity_providers"
  }
}