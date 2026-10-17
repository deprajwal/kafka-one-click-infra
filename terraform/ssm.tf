
# Create a private S3 bucket for Ansible SSM file transfers.
resource "aws_s3_bucket" "ssm_transfer" {
  bucket = "kafka-one-click-ssm-506192652789"

  tags = {
    Name    = "kafka-one-click-ssm-transfer"
    Project = "kafka-one-click-infra"
  }
}

# Block all public access to the SSM transfer bucket.
resource "aws_s3_bucket_public_access_block" "ssm_transfer" {
  bucket = aws_s3_bucket.ssm_transfer.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption for transferred files.
resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_transfer" {
  bucket = aws_s3_bucket.ssm_transfer.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Prevent accidental public ACLs on uploaded objects.
resource "aws_s3_bucket_ownership_controls" "ssm_transfer" {
  bucket = aws_s3_bucket.ssm_transfer.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
