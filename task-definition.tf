resource "aws_ecs_task_definition" "my-task-definition" {
  family                   = "my-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = module.ecs_task_execution_role.arn
  # Yep, I know I'm re using the TER
  task_role_arn = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "envoy"
      image     = "${aws_ecr_repository.my-ecr-repo.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8888
          hostPort      = 8888
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "awslogs-ecs"
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "awslogs-envoy"
        }
      }
    },
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
          awslogs-create-group  = "true"
          awslogs-group         = "awslogs-ecs"
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "awslogs-httpbin"
        }
      }
    }
  ])
  depends_on = [null_resource.docker_packaging]
}
