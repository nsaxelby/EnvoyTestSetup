resource "aws_s3_bucket" "flink-apps" {
  bucket = "flink-apps-ns123"

  force_destroy = true
  tags = {
    Name = "flink-apps"
  }
}

module "aws_logs" {
  source = "trussworks/logs/aws"
  version = "~> 16.0"
  s3_bucket_name = "my-log-bucket-nlb"
  default_allow = false
  allow_alb = true
  allow_nlb = true
  create_public_access_block = true
  versioning_status = "Enabled"
  force_destroy = true
}
