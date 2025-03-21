provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer-key" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/TCaHHn0FEH8LwcFDFB1auBt9dc5OFqfbF6dCsuey+ naveencomputerengineer@gmail.com"
}

resource "aws_instance" "example" {
  ami                  = "ami-0b0ea68c435eb488d"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.my_ec2_instance_profile.name
  monitoring           = true
  ebs_optimized        = true
  key_name             = "deployer-key"
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  user_data = <<-EOF
              #!/bin/bash

              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable --now httpd
              echo "Hello, World from $hostname" > /var/www/html/index.html
              EOF
}

resource "aws_iam_role" "my_ec2_role" {
  name = "my-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "my_role_policy_attachment" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "my_ec2_instance_profile" {
  name = "my-ec2-instance-profile"
  role = aws_iam_role.my_ec2_role.name
}
