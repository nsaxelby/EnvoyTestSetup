resource "aws_lb_listener" "my-listener" {
  load_balancer_arn = aws_lb.my-nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
