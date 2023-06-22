resource "aws_lb_target_group" "my-target-group" {
  name                 = "my-target-group"
  port                 = 8888
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main.id
  proxy_protocol_v2    = true
  deregistration_delay = 5
  health_check {
    healthy_threshold   = 2
    interval            = 5
    timeout             = 5
    protocol            = "TCP"
    unhealthy_threshold = 2
  }
}
