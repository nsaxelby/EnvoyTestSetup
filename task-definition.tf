resource "aws_ecs_task_definition" "my-task-definition" {
  family                   = "my-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = module.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "httpbin"
      image     = "kennethreitz/httpbin"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group        = "awslogs-ecs"
          awslogs-region       = "eu-west-1"
          awslogs-stream-prefix : "awslogs-httpbin"
        }
      }
    }
  ])
}
