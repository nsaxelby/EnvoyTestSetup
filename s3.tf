resource "aws_s3_bucket" "flink-apps" {
  bucket = "flink-apps-ns123"

  tags = {
    Name = "flink-apps"
  }
}
