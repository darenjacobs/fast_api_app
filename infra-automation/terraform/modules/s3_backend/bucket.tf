/*===========================================
        KMS Key to Encrypt S3 Bucket
============================================*/

resource "aws_kms_key" "mykey" {
  description             = "KMS key for encrypting S3 bucket"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_key_rotation
  tags = {
    Name = "KMS Key for S3 bucket"
  }
}

/*=====================
        S3 Bucket
======================*/

resource "aws_s3_bucket" "state" {
  bucket = var.s3_bucket_name
  force_destroy = var.s3_bucket_force_destroy

   tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption using the AWS KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.mykey.arn
      }
    }
  }

# Properly configure public access blocks
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
