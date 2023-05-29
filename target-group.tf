resource "aws_lb_target_group" "my-target-group" {
  name        = "my-target-group"
  port        = 8888
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}
