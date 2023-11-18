resource "aws_secretsmanager_secret" "secretsmanager-secret-for-msk" {
  count                   = local.kafka_msk_enabled ? 1 : 0
  kms_key_id              = aws_kms_key.kms[0].id
  recovery_window_in_days = 0
  name                    = "AmazonMSK_secretz-for-msk"
}

resource "aws_secretsmanager_secret_version" "secret-version-kafka" {
  count         = local.kafka_msk_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.secretsmanager-secret-for-msk[0].id
  secret_string = jsonencode({ username = local.kafka_username, password = local.kafka_password })
}

data "aws_iam_policy_document" "secret-policy-msk" {
  count = local.kafka_msk_enabled ? 1 : 0
  statement {
    sid    = "AWSKafkaResourcePolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.secretsmanager-secret-for-msk[0].arn]
  }
}

resource "aws_secretsmanager_secret_policy" "msk-secret-policy" {
  count      = local.kafka_msk_enabled ? 1 : 0
  secret_arn = aws_secretsmanager_secret.secretsmanager-secret-for-msk[0].arn
  policy     = data.aws_iam_policy_document.secret-policy-msk[0].json
}

resource "aws_msk_scram_secret_association" "example" {
    count      = local.kafka_msk_enabled ? 1 : 0
  cluster_arn     = aws_msk_cluster.example[0].arn
  secret_arn_list = [aws_secretsmanager_secret.secretsmanager-secret-for-msk[0].arn]

  depends_on = [aws_secretsmanager_secret_version.secret-version-kafka]
}