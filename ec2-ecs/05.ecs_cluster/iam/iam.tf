####################################################################################################
# ecs_task_role
####################################################################################################
resource "aws_iam_role" "sample_ecs_task_role" {
  name = "sample_${var.prefix}_ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sample_ecs_task_role_policy" {
  name = "sample_${var.prefix}_ecs_task_role_policy"
  role = aws_iam_role.sample_ecs_task_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      }
    ]
  })
}

/*
resource "aws_iam_policy_attachment" "sample_ecs_task_role_full_permissions" {
  name       = "sample_${var.prefix}_ecs_task_role_full_permissions"
  roles      = [aws_iam_role.sample_ecs_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
*/

resource "aws_iam_role_policy_attachment" "sample_ecs_task_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.sample_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

####################################################################################################
# ecs_task_execution_role
####################################################################################################
resource "aws_iam_role" "sample_ecs_task_execution_role" {
  name = "sample_${var.prefix}_ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy" "sample_ecs_execution_role_policy" {
  name = "sample_${var.prefix}_ecs_execution_role_policy"
  role = aws_iam_role.sample_ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "sample_ecs_execution_role_basic_permissions" {
  name       = "sample_${var.prefix}_ecs_execution_role_basic_permissions"
  roles = [aws_iam_role.sample_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/*
resource "aws_iam_policy_attachment" "sample_ecs_execution_role_full_permissions" {
  name       = "sample_${var.prefix}_ecs_execution_role_full_permissions"
  roles      = [aws_iam_role.sample_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
*/

resource "aws_iam_role_policy_attachment" "sample_ecs_task_execution_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.sample_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

####################################################################################################
# ecs_instance_role
####################################################################################################
resource "aws_iam_instance_profile" "sample_ecs_instance_profile" {
  name = "sample_${var.prefix}_ecs_instance_profile"
  role = aws_iam_role.sample_ecs_instance_role.name
}

resource "aws_iam_role" "sample_ecs_instance_role" {
  name = "sample_${var.prefix}_ecs_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sample_ecs_additional_policy" {
  name = "sample_${var.prefix}_ecs_additional_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity",
          "ec2:DescribeInstances",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeContainerInstances",
          "ecs:ListContainerInstances",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListTasks",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sample_ecs_instance_role_attachment" {
  role       = aws_iam_role.sample_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "sample_ecs_additional_policy_attachment" {
  role       = aws_iam_role.sample_ecs_instance_role.name
  policy_arn = aws_iam_policy.sample_ecs_additional_policy.arn
}
/*
resource "aws_iam_role_policy_attachment" "sample_ecs_instance_full_access" {
  role       = aws_iam_role.sample_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
*/

resource "aws_iam_role_policy_attachment" "sample_ecs_instance_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.sample_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

####################################################################################################
# application_autoscaling_role
####################################################################################################
resource "aws_iam_role" "sample_ecs_autoscale_role" {
  name = "sample_${var.prefix}_ecs_autoscale_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sample_ecs_autoscale_policy_attachment" {
  role       = aws_iam_role.sample_ecs_autoscale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
/*
resource "aws_iam_policy" "sample_ecs_autoscale_cloudwatch_policy" {
  name = "sample_${var.prefix}_ecs_autoscale_cloudwatch_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:SetAlarmState",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_additional_permissions" {
  role       = aws_iam_role.sample_ecs_autoscale_role.name
  policy_arn = aws_iam_policy.sample_ecs_autoscale_cloudwatch_policy.arn
}
*/