# ecr 접근을 위한 IAM Role 생성
resource "aws_iam_role" "sample_ecr_access_role" {
  name = "sample_${var.prefix}_ecr_access_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# ecr 접근을 위한 IAM Policy 생성
resource "aws_iam_policy" "sample_ecr_access_policy" {
  name = "sample_${var.prefix}_ecr_access_policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sample_live_ecr_policy_attachment" {
  role       = aws_iam_role.sample_ecr_access_role.name
  policy_arn = aws_iam_policy.sample_ecr_access_policy.arn
}
