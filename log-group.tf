resource "aws_cloudwatch_log_group" "awslogs-ecs" {
  name = "awslogs-ecs"
}

resource "aws_cloudwatch_log_group" "network-firewall-log-group" {
  name = "network-firewall-log-group"
}

resource "aws_cloudwatch_log_group" "fluent-bit-cloudwatch" {
  name = "fluent-bit-cloudwatch"
}
