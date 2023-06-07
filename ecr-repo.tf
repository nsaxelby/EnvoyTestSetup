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


resource "aws_ecr_repository" "my-ecr-repo-fluent" {
  name         = "my-ecr-repo-fluent"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "default_policy_fluent" {
  repository = aws_ecr_repository.my-ecr-repo-fluent.name

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
