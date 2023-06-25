
resource "aws_lambda_function" "kinesis-cw-log-transformer" {
  description      = "Transforms base64 gzipped messages from CW"
  filename         = "lambda_function_payload.zip"
  function_name    = "cloudwatch-logs-transformer-lambda"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda-role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 60
  memory_size      = 512

  environment {
    variables = {
      KINESIS_STREAM = aws_kinesis_stream.envoy_ip_records.arn
    }
  }
  depends_on = [aws_kinesis_stream.envoy_ip_records]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name               = "iam_role_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-basic-exec" {
  role       = aws_iam_role.lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_pol" {
  name = "lambda_pol"
  path = "/"
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

resource "aws_iam_role_policy_attachment" "lambda-pol-attachment" {
  role       = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda_pol.arn
}

resource "aws_lambda_event_source_mapping" "k-cw-transformer-mapper" {
  event_source_arn                   = aws_kinesis_stream.log_output.arn
  function_name                      = aws_lambda_function.kinesis-cw-log-transformer.arn
  starting_position                  = "LATEST"
  batch_size                         = 5
  maximum_batching_window_in_seconds = 1

  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.lambda-transform-dlq.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.lambda-pol-attachment]
}

resource "aws_sqs_queue" "lambda-transform-dlq" {
  name = "lambda-transform-dlq"
}
