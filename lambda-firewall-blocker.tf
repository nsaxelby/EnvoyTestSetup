
resource "aws_lambda_function" "sqs-firewall-blocker-lambda" {
  count            = local.network_firewall_enabled ? 1 : 0
  description      = "Blocks in network firewall lambda"
  filename         = "lambda_firewall_blocker.zip"
  function_name    = "sqs-firewall-blocker-lambda"
  handler          = "lambda_firewall_blocker.lambda_handler"
  role             = aws_iam_role.lambda-role-fwb[0].arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambdafile[0].output_base64sha256
  timeout          = 20
  memory_size      = 512
  publish          = true

  environment {
    variables = {
      NETWORK_FIREWALL_POLICY_ARN     = aws_networkfirewall_firewall_policy.myfwpolicy[0].arn
      NETWORK_FIREWALL_ARN            = aws_networkfirewall_firewall.nwfw[0].arn
      NETWORK_FIREWALL_RULE_GROUP_ARN = aws_networkfirewall_rule_group.my-stateless-rule-group[0].arn
    }
  }
  depends_on = [aws_sqs_queue.alert-kda-events]
}

data "archive_file" "lambdafile" {
  count       = local.network_firewall_enabled ? 1 : 0
  type        = "zip"
  source_file = "lambda_firewall_blocker.py"
  output_path = "lambda_firewall_blocker.zip"
}

data "aws_iam_policy_document" "assume_role_policy-fw-blocker" {
  count = local.network_firewall_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role-fwb" {
  count              = local.network_firewall_enabled ? 1 : 0
  name               = "iam_role_for_lambda_fwb"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy-fw-blocker[0].json
}

resource "aws_iam_role_policy_attachment" "lambda-basic-exec-fwb" {
  count      = local.network_firewall_enabled ? 1 : 0
  role       = aws_iam_role.lambda-role-fwb[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_pol-fwb" {
  count = local.network_firewall_enabled ? 1 : 0
  name  = "lambda_pol_fwb"
  path  = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "kinesis:*",
          "sqs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "network-firewall:*",
          "network-firewall:DescribeFirewallPolicy"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "stream:GetRecord",
          "stream:GetShardIterator",
          "stream:DescribeStream",
          "stream:ListStreams",
          "stream:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-pol-attachment-fwb" {
  count      = local.network_firewall_enabled ? 1 : 0
  role       = aws_iam_role.lambda-role-fwb[0].name
  policy_arn = aws_iam_policy.lambda_pol-fwb[0].arn
}

resource "aws_lambda_event_source_mapping" "s-fw-blocker-mapper" {
  count                              = local.network_firewall_enabled ? 1 : 0
  event_source_arn                   = aws_sqs_queue.alert-kda-events.arn
  function_name                      = aws_lambda_function.sqs-firewall-blocker-lambda[0].arn
  batch_size                         = 1
  maximum_batching_window_in_seconds = 1
  depends_on                         = [aws_iam_role_policy_attachment.lambda-pol-attachment]
}

resource "aws_sqs_queue" "lambda-firewall-blocker-dlq" {
  count = local.network_firewall_enabled ? 1 : 0
  name  = "lambda-firewall-blocker-dlq"
}

resource "aws_lambda_provisioned_concurrency_config" "concur_config" {
  count                             = local.network_firewall_enabled ? 1 : 0
  function_name                     = aws_lambda_function.sqs-firewall-blocker-lambda[0].function_name
  provisioned_concurrent_executions = 1
  qualifier                         = aws_lambda_function.sqs-firewall-blocker-lambda[0].version
}
