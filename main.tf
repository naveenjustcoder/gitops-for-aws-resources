# Define provider (AWS)
provider "aws" {
  region = "us-east-1"  # Change this to your desired region - done
}

# VPC configuration
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "prod-vpc"
  }
}

# Subnet configuration
resource "aws_subnet" "prod_subnet" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "prod-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id
}

# Security Group configuration
resource "aws_security_group" "prod_sg" {
  vpc_id = aws_vpc.prod_vpc.id
  name        = "prod-sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere, change as per your security policy
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 instance
# resource "aws_iam_role" "ec2_role" {
#   name = "prod-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# IAM Policy Attachment for EC2 role
# resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
#   name       = "ec2-attach-policy"
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
#   roles      = [aws_iam_role.ec2_role.name]
# }

# EC2 Key Pair for SSH access
resource "aws_key_pair" "prod_key" {
  key_name   = "prod-key"
#    public_key = file("~/.ssh/id_ed25519.pub")  # Replace with your actual public key file path
   public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/TCaHHn0FEH8LwcFDFB1auBt9dc5OFqfbF6dCsuey+ naveencomputerengineer@gmail.com"
}

# EC2 Instance Configuration
resource "aws_instance" "prod_instance" {
  ami             = "ami-0b0ea68c435eb488d"  # Replace with the correct AMI ID for your region
  instance_type   = "t2.micro"     # Adjust instance size as per your needs
  subnet_id       = aws_subnet.prod_subnet.id
  key_name        = aws_key_pair.prod_key.key_name
#   security_groups = [aws_security_group.prod_sg.name]
#   iam_instance_profile = aws_iam_role.ec2_role.name

  tags = {
    Name = "prod-instance"
  }

  # Optional: Enable detailed monitoring
  monitoring = true

  # CloudWatch Logs configuration (optional but recommended for production)
  user_data = <<-EOT
              #!/bin/bash
              sudo apt update && apt install -y awslogs
              sudo systemctl enable --now awslogsd
              EOT
}

# Elastic IP (optional, to keep the IP static)
resource "aws_eip" "prod_eip" {
  instance = aws_instance.prod_instance.id
}

# Output instance public IP
output "instance_public_ip" {
  value = aws_instance.prod_instance.public_ip
}

# Output instance private IP
output "instance_private_ip" {
  value = aws_instance.prod_instance.private_ip
}

# Output Elastic IP
output "elastic_ip" {
  value = aws_eip.prod_eip.public_ip
}
