
resource "aws_lambda_function" "kinesis-kda-alert-processor" {
  description      = "Listens to events on kinesis kda alert stream"
  filename         = "kinesis_kda_alert_procesor.zip"
  function_name    = "kinesis-kda-alert-processor-lambda"
  handler          = "kinesis_kda_alert_procesor.lambda_handler"
  role             = aws_iam_role.lambda-role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda1.output_base64sha256
  timeout          = 60
  memory_size      = 512

  environment {
    variables = {
      SQS_OUTPUT_STREAM = aws_sqs_queue.alert-kda-events.url
    }
  }
  depends_on = [aws_kinesis_stream.envoy_ip_records_processed_from_kda]
}

data "archive_file" "lambda1" {
  type        = "zip"
  source_file = "kinesis_kda_alert_procesor.py"
  output_path = "kinesis_kda_alert_procesor.zip"
}

data "aws_iam_policy_document" "assume_role_policy1" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role1" {
  name               = "iam_role_for_kda_alert_processor_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy1.json
}

resource "aws_iam_role_policy_attachment" "lambda-basic-exec1" {
  role       = aws_iam_role.lambda-role1.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_pol1" {
  name = "lambda_pol1"
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

resource "aws_iam_role_policy_attachment" "lambda-pol-attachment1" {
  role       = aws_iam_role.lambda-role1.name
  policy_arn = aws_iam_policy.lambda_pol1.arn
}

resource "aws_lambda_event_source_mapping" "k-kda-alerter-mapper" {
  event_source_arn                   = aws_kinesis_stream.envoy_ip_records_processed_from_kda.arn
  function_name                      = aws_lambda_function.kinesis-kda-alert-processor.arn
  starting_position                  = "LATEST"
  batch_size                         = 1
  maximum_batching_window_in_seconds = 1
  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.lambda-kda-alert-dlq.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.lambda-pol-attachment1]
}

resource "aws_sqs_queue" "lambda-kda-alert-dlq" {
  name = "lambda-kda-alert-dlq"
}


resource "aws_sqs_queue" "alert-kda-events" {
  name = "alert-kda-events"
}
