terraform {
  backend "s3" {
    bucket = "sample-tf-state"
    key    = "prod/12.chatbot/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

variable "region" {
  type = string
  # default = "ap-northeast-2"
  default = "ap-northeast-1"
}

# environment = "prod" # dev, qa, lqa, fgt, stage, prod
variable "prefix" {
  type    = string
  default = "prod"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_sns_topic" "sample_chatbot_topic" {
  name = "sample-${var.prefix}-chatbot-sns-topic"
}

resource "aws_sns_topic_policy" "sample_chatbot_topic_policy" {
  arn = aws_sns_topic.sample_chatbot_topic.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        "Action" : [
          "SNS:Publish",
          "SNS:RemovePermission",
          "SNS:SetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:AddPermission",
          "SNS:Subscribe"
        ],
        Resource = aws_sns_topic.sample_chatbot_topic.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "sample_ecs_state_changed_rule" {
  name        = "sample-${var.prefix}-ecs-state-changed-rule"
  description = "ECS Task State Change event"
  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail-type" : ["ECS Task State Change"]
  })
}

resource "aws_cloudwatch_event_target" "sample_ecs_state_changed_event_target" {
  rule      = aws_cloudwatch_event_rule.sample_ecs_state_changed_rule.name
  target_id = "sample-ecs-state-changed-target"
  arn       = aws_sns_topic.sample_chatbot_topic.arn
}
