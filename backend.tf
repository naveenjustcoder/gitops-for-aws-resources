terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-naveenyash"     # Your S3 bucket name
    key            = "path/to/terraform.tfstate"     # Path to store the state in the bucket
    region         = "us-east-1"                     # Your AWS region
    dynamodb_table = "terraform-lock-table"         # Your DynamoDB table for locking
    encrypt        = true                           # Enable encryption for state file (recommended)
    acl            = "bucket-owner-full-control"    # Set ACL permissions
  }
}