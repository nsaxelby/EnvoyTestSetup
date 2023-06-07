
resource "null_resource" "docker_packaging_fluentbit" {

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com
    docker build -t "${aws_ecr_repository.my-ecr-repo-fluent.repository_url}:latest" -f fluentbit/Dockerfile fluentbit
    docker push "${aws_ecr_repository.my-ecr-repo-fluent.repository_url}:latest"
    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_repository.my-ecr-repo-fluent,
  ]
}
