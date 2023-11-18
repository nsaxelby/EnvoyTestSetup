resource "aws_s3_bucket" "flink-apps" {
  bucket = "flink-apps-ns123"

  force_destroy = true
  tags = {
    Name = "flink-apps"
  }
}

resource "aws_s3_bucket" "msk-logs-bucket" {
  count  = local.kafka_msk_enabled ? 1 : 0
  bucket = "msk-broker-logs-bucket-ns-test-buck"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count      = local.kafka_msk_enabled ? 1 : 0
  bucket     = aws_s3_bucket.msk-logs-bucket[0].id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership[0]]

}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  count  = local.kafka_msk_enabled ? 1 : 0
  bucket = aws_s3_bucket.msk-logs-bucket[0].id
  rule {
    object_ownership = "ObjectWriter"
  }
}
