provider "aws" {
  region = "us-east-1"  # Choose your desired AWS region
}

# resource "aws_s3_bucket_versioning" "com-div-proj-comp-s3-bucket-versioning" {
#   bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_acl" "com-div-proj-comp-s3-bucket-acl" {
#   bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "com-div-proj-comp-s3-bucket-sse" {
#   bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# Create an S3 Bucket
resource "aws_s3_bucket" "com-div-proj-comp-s3-bucket" {
  bucket_prefix = "com.div.proj.comp"  # Bucket name must be globally unique
}

# # Optional: Create a bucket for logging
# resource "aws_s3_bucket" "com.div.proj.comp.s3-LOG-BUCKET" {
#   bucket = "my-log-bucket"  # Replace with a unique bucket name
# }

# resource "aws_s3_bucket_acl" "com.div.proj.comp.s3-LOG-BUCKET-acl" {
#   bucket = aws_s3_bucket.com.div.proj.comp.s3-bucket.id
#   acl    = "log-delivery-write"
# }

# Outputs for reference
output "s3_bucket_name" {
  value = aws_s3_bucket.com.div.proj.comp.s3-bucket.bucket
}

# output "log_bucket_name" {
#   value = aws_s3_bucket.com.div.proj.comp.s3-log-bucket.bucket
# }
