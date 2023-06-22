resource "aws_cloudwatch_log_group" "awslogs-ecs" {
  name = "awslogs-ecs"
}

resource "aws_cloudwatch_log_group" "network-firewall-log-group" {
  name = "network-firewall-log-group"
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch-kinesis-subscription" {
  name            = "accesslogs_kinesis_sub"
  role_arn        = aws_iam_role.cloudwatch_sub_role.arn
  log_group_name  = aws_cloudwatch_log_group.awslogs-ecs.name
  filter_pattern  = "remote_ip response_code"
  destination_arn = aws_kinesis_stream.log_output.arn
  distribution    = "Random"
  depends_on      = [aws_iam_role_policy_attachment.cloudwatch-sub-pol-attachment]
}


resource "aws_iam_role" "cloudwatch_sub_role" {
  name               = "cloudwatch_sub_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "logs.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_sub_pol" {
  name = "cloudwatch-sub-pol"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:PutRecord"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch-sub-pol-attachment" {
  role       = aws_iam_role.cloudwatch_sub_role.name
  policy_arn = aws_iam_policy.cloudwatch_sub_pol.arn
}
