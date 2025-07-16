###############################################################################
# Amazon S3                                                                    #
###############################################################################

resource "random_string" "bucket_suffix" {
  length  = 8
  uppercase = false
  numeric   = true
  special   = false
}

resource "aws_s3_bucket" "assets" {
  bucket = "jargon-ai-assets-${var.environment}-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name = "jargon-assets-${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}