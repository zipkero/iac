resource "aws_launch_template" "sample_http_game_launch_template" {
  name_prefix   = "sample_${var.prefix}_http_game_launch_template_"
  image_id      = "ami-0e993a27d22fca827"
  instance_type = "t2.small"
  key_name      = "sample_prod_keypair"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.http_game_template_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash

echo ECS_CLUSTER=sample_${var.prefix}_ecs_cluster | sudo tee -a /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"ServiceName": "sample_${var.prefix}_http_game"}' >> /etc/ecs/ecs.config

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      ServiceName = "sample_${var.prefix}_http_game"
    }
  }
}

