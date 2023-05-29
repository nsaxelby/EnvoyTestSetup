module "ecs_task_execution_role" {
  source = "dod-iac/ecs-task-execution-role/aws"

  allow_create_log_groups    = true
  allow_ecr                  = true
  cloudwatch_log_group_names = ["*"]
  name                       = format("app-%s-task-execution-role", "my-app")

  tags = {
    Application = "my-app"
    Automation  = "Terraform"
  }
}
