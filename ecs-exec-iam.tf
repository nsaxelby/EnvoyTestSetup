# module "ecs_task_execution_role" {
#   source = "dod-iac/ecs-task-execution-role/aws"

#   allow_create_log_groups    = true
#   allow_ecr                  = true
#   cloudwatch_log_group_names = ["*"]       

#   tags = {
#     Application = "my-app"
#     Automation  = "Terraform"
#   }
# }

locals {
  name = format("app-%s-task-execution-role", "my-app")
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

#
# IAM
#

data "aws_iam_policy_document" "assume_role_policy_exec" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs-exec-iam-role" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_exec.json
}

data "aws_iam_policy_document" "ecs-exec-iam-pol-document" {
  dynamic "statement" {
    for_each = [true]
    content {
      sid = "CreateCloudWatchLogGroups"
      actions = [
        "logs:CreateLogGroup"
      ]
      effect = "Allow"
      resources = formatlist(
        format(
          "arn:%s:logs:*:*:log-group:%%s/*",
          data.aws_partition.current.partition
        ),
        ["*"]
      )
    }
  }
  statement {
    sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = formatlist(
      format(
        "arn:%s:logs:%s:%s:log-group:%%s:log-stream:*",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
      ),
      ["*"]
    )
  }
  dynamic "statement" {
    for_each = [true]
    content {
      sid = "GetContainerImage"
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
      effect    = "Allow"
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "ecs-exec-policy" {
  name        = format("%s-policy", local.name)
  description = format("The policy for %s.", local.name)
  policy      = data.aws_iam_policy_document.ecs-exec-iam-pol-document.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.ecs-exec-iam-role.name
  policy_arn = aws_iam_policy.ecs-exec-policy.arn
}