resource "aws_s3_bucket" "flink-apps" {
  bucket = "flink-apps-ns123"

  force_destroy = true
  tags = {
    Name = "flink-apps"
  }
}
