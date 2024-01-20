resource "null_resource" "docker-packaging-otel-image" {
  count      = local.kafka_msk_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
    BROKERS=$(aws kafka get-bootstrap-brokers --cluster-arn ${aws_msk_cluster.example[0].arn} --region=eu-west-1 | jq -r '.BootstrapBrokerStringSaslScram')
    echo $BROKERS
    docker build -t "${aws_ecr_repository.otel-collector-repo-ecr[0].repository_url}:latest" -f OtelCollectorDockerfile --build-arg BROKERS="$BROKERS" .
    docker push "${aws_ecr_repository.otel-collector-repo-ecr[0].repository_url}:latest"
    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_lifecycle_policy.default-policy-otel-repo,
    aws_msk_cluster.example,
  ]
}