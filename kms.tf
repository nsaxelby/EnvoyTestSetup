resource "aws_kms_key" "kms" {
  count       = local.kafka_msk_enabled ? 1 : 0
  description = "example"
}
