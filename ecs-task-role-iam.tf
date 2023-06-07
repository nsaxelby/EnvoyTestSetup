resource "aws_iam_role" "ecs_task_role" {
  name               = "ec2_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policyy" {
  name = "my-pol"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:*",
          "ecr:*",
          "kinesis:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.policyy.arn
}


