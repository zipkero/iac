output "ecs_instance_profile_name" {
  value = aws_iam_instance_profile.sample_ecs_instance_profile.name
}

output "ecs_task_role_arn" {
  value = aws_iam_role.sample_ecs_task_role.arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.sample_ecs_task_execution_role.arn
}







