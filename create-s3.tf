provider "aws" {
  region = "us-east-1"  # Choose your desired AWS region
}

resource "aws_s3_bucket" "com_div_proj_comp_s3_bucket" {
  bucket_prefix = "com.div.proj.comp"  # Bucket name must be globally unique
}
resource "aws_s3_bucket_server_side_encryption_configuration" "com_div_proj_comp_s3_bucket-sse" {
  bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "com_div_proj_comp_s3_bucket_versioning" {
  bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id      = "expire"
    status  = "Enabled"
    filter{
      prefix = "logs/"
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 90
    }
  }
  rule {
    id = "failed_uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
  }
}
resource "aws_s3_bucket_public_access_block" "com_div_proj_comp_s3_bucket_block_public_access" {
  bucket = aws_s3_bucket.com_div_proj_comp_s3_bucket.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls=true
}
resource "aws_sns_topic" "com_div_proj_comp_sns_topic" {
  name = "com.div.proj.comp.s3-bucket-notifications"
  kms_master_key_id = "alias/aws/sns"
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.com_div_proj_comp_s3_bucket.id
  topic {
    topic_arn     = aws_sns_topic.com_div_proj_comp_sns_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}

# Optional: Create a bucket for logging
resource "aws_s3_bucket" "com_div_proj_comp_s3_LOG_BUCKET" {
  bucket = "com.div.proj.comp.s3-log-bucket"  # Replace with a unique bucket name
}
resource "aws_s3_bucket_acl" "com-div-proj-comp-s3-LOG-BUCKET-acl" {
  bucket = aws_s3_bucket.com_div_proj_comp_s3_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "com_div_proj_comp_s3_bucket_logging" {
  bucket = aws_s3_bucket.com_div_proj_comp_s3_bucket.id
  target_bucket = aws_s3_bucket.com_div_proj_comp_s3_LOG_BUCKET.id
  target_prefix = "logs/"
}
resource "aws_sns_topic" "com_div_proj_comp_log_bucket_sns_topic" {
  name = "com.div.proj.comp.s3-log-bucket-notifications"
  kms_master_key_id = "alias/aws/sns"
}
resource "aws_s3_bucket_notification" "log_bucket_notification" {
  bucket = aws_s3_bucket.com.div.proj.comp.s3-log-bucket.id
  topic {
    topic_arn     = aws_sns_topic.com_div_proj_comp_log_bucket_sns_topic.arn
    events        = ["s3:ObjectRemoved:*"]
    filter_prefix = "logs/"
  }
}


# Outputs for reference
output "s3_bucket_name" {
  value = aws_s3_bucket.com_div_proj_comp_s3_bucket.bucket
}

output "log_bucket_name" {
  value = aws_s3_bucket.com_div_proj_comp_s3_LOG_BUCKET.bucket
}
