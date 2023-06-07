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
    },
    {
      essential = true,
      image     = "${aws_ecr_repository.my-ecr-repo-fluent.repository_url}:latest"
      cpu       = 32
      memory    = 64
      name      = "log_router"
      firelensConfiguration = {
        type = "fluentbit"
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "awslogs-ecs"
          awslogs-region        = "eu-west-1"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "firelens"
        }
      }
      memoryReservation = 50
    },
    {
      name      = "envoy"
      image     = "${aws_ecr_repository.my-ecr-repo.repository_url}:latest"
      cpu       = 480
      memory    = 960
      essential = true
      portMappings = [
        {
          containerPort = 8888
          hostPort      = 8888
        }
      ]
      logConfiguration = {
        logDriver = "awsfirelens"
      }
    }
  ])
  depends_on = [null_resource.docker_packaging, null_resource.docker_packaging_fluentbit]
}
