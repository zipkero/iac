resource "aws_launch_template" "sample_http_report_launch_template" {
  name_prefix = "sample_${var.prefix}_http_report_launch_template_"
  # image_id      = "ami-07d95467596b97099"
  image_id = "ami-03507a48be45b34e7"
  # instance_type = "t3.micro"
  instance_type = "t2.medium"
  key_name      = "sample_keypair"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.http_report_template_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash

echo ECS_CLUSTER=sample_${var.prefix}_ecs_cluster | sudo tee -a /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"ServiceName": "sample_${var.prefix}_http_report"}' >> /etc/ecs/ecs.config

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      ServiceName = "sample_${var.prefix}_http_report"
    }
  }
}

resource "aws_launch_template" "sample_http_game_launch_template" {
  name_prefix = "sample_${var.prefix}_http_game_launch_template_"
  # image_id      = "ami-07d95467596b97099"
  image_id = "ami-03507a48be45b34e7"
  # instance_type = "c5.large"
  instance_type = "t2.medium"
  key_name      = "sample_keypair"

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

resource "aws_launch_template" "sample_tcp_master_launch_template" {
  name_prefix = "sample_${var.prefix}_tcp_master_launch_template_"
  # image_id      = "ami-07d95467596b97099"
  image_id = "ami-03507a48be45b34e7"
  # instance_type = "t3.large"
  instance_type = "t2.medium"
  key_name      = "sample_keypair"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.tcp_master_template_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash

echo ECS_CLUSTER=sample_${var.prefix}_ecs_cluster | sudo tee -a /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"ServiceName": "sample_${var.prefix}_tcp_master"}' >> /etc/ecs/ecs.config

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      ServiceName = "sample_${var.prefix}_tcp_master"
    }
  }
}

resource "aws_launch_template" "sample_tcp_social_launch_template" {
  name_prefix = "sample_${var.prefix}_tcp_social_launch_template_"
  # image_id      = "ami-07d95467596b97099"
  image_id = "ami-03507a48be45b34e7"
  # instance_type = "t3.medium"
  instance_type = "t2.medium"
  key_name      = "sample_keypair"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.tcp_social_template_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash

echo ECS_CLUSTER=sample_${var.prefix}_ecs_cluster | sudo tee -a /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"ServiceName": "sample_${var.prefix}_tcp_social"}' >> /etc/ecs/ecs.config

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      ServiceName = "sample_${var.prefix}_tcp_social"
    }
  }
}

resource "aws_launch_template" "sample_http_backoffice_launch_template" {
  name_prefix = "sample_${var.prefix}_http_backoffice_launch_template_"
  # image_id      = "ami-07d95467596b97099"
  image_id = "ami-03507a48be45b34e7"
  instance_type = "t2.medium"
  key_name      = "sample_keypair"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.http_backoffice_template_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash

echo ECS_CLUSTER=sample_${var.prefix}_ecs_cluster | sudo tee -a /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true | sudo tee -a /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"ServiceName": "sample_${var.prefix}_http_backoffice"}' >> /etc/ecs/ecs.config

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      ServiceName = "sample_${var.prefix}_http_backoffice"
    }
  }
}