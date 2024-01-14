locals {
  buildtime = formatdate("YYYYMMDDhhmmss", timestamp())
}

resource "null_resource" "build-flink-jar" {
  provisioner "local-exec" {
    command = <<EOF
    docker run --rm --name my-maven-project -v "$(pwd)"/FlinkStreamingApp:/usr/src/mymaven -w /usr/src/mymaven maven:3.9.6-amazoncorretto-21 mvn clean package
    mv FlinkStreamingApp/target/envoy-test-flink-app-1.0.jar FlinkStreamingApp/target/${local.buildtime}.jar
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

