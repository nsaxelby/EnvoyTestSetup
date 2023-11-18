resource "aws_cloudwatch_log_group" "kafka-cw-logs" {
  count = local.kafka_msk_enabled ? 1 : 0
  name  = "msk_broker_logs"
}
