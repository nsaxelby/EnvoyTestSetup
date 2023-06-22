resource "null_resource" "docker_packaging" {

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com
    docker build -t "${aws_ecr_repository.my-ecr-repo.repository_url}:latest" -f Dockerfile .
    docker push "${aws_ecr_repository.my-ecr-repo.repository_url}:latest"
    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_repository.my-ecr-repo,
  ]
}

