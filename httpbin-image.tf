resource "null_resource" "docker-packaging-httpbin-image" {
  provisioner "local-exec" {
    command = <<EOF
    docker build -t "${aws_ecr_repository.httpbin-repo-ecr.repository_url}:latest" -f HttpbinDockerfile .
    docker push "${aws_ecr_repository.httpbin-repo-ecr.repository_url}:latest"
    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_lifecycle_policy.default-policy-httpbin-repo
      ]
}