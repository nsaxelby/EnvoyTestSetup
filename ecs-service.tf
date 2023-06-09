resource "aws_ecs_cluster" "my-cluster" {
  name = "my-cluster"
}

resource "aws_ecs_service" "my-service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my-cluster.id
  task_definition = aws_ecs_task_definition.my-task-definition.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my-target-group.arn
    container_name   = "envoy"
    container_port   = 8888
  }

  depends_on = [aws_lb_listener.my-listener]
}


resource "aws_security_group" "ecs-sg" {
  name        = "ecs-sg-allow-nlb"
  description = "Allow inbound traffic from nlb on 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "80 from vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "8888 from vpc"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "ecs-sg"
  }
}
