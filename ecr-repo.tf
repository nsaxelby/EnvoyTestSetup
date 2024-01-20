resource "aws_ecr_repository" "my-ecr-repo" {
  name         = "my-ecr-repo"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "default_policy" {
  repository = aws_ecr_repository.my-ecr-repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the last 2 untagged images.",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}



resource "aws_ecr_repository" "otel-collector-repo-ecr" {
  count        = local.kafka_msk_enabled ? 1 : 0
  name         = "otel-collector-repo-ecr"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "default-policy-otel-repo" {
  count      = local.kafka_msk_enabled ? 1 : 0
  repository = aws_ecr_repository.otel-collector-repo-ecr[0].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the last 2 untagged images.",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


resource "aws_ecr_repository" "httpbin-repo-ecr" {
  name         = "httpbin-repo-ecr"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "default-policy-httpbin-repo" {
  repository = aws_ecr_repository.httpbin-repo-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the last 2 untagged images.",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
