
resource "aws_lambda_function" "kinesis-cw-log-transformer" {
  description      = "Transforms base64 gzipped messages from CW"
  filename         = "lambda_function_payload.zip"
  function_name    = "cloudwatch-logs-transformer-lambda"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda.output_base64sha256
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

resource "aws_iam_role" "lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
