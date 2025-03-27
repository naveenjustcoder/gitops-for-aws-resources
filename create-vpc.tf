# Provider configuration
provider "aws" {
  region = "us-east-1"  # Set the region to your desired AWS region
}

# Create a VPC
resource "aws_vpc" "com_div_proj_comp_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "com.div.proj.comp.vpc"
  }
}

resource "aws_flow_log" "com_div_proj_comp_vpc_flow_log" {
  traffic_type = "ALL"
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
}

# Create a public subnet
resource "aws_subnet" "com_div_proj_comp_vpc_public_subnet" {
  vpc_id     = aws_vpc.com_div_proj_comp_vpc.id
  cidr_block = "10.0.1.0/24"  # Define subnet CIDR block for public subnet
  availability_zone = "us-east-1a"  # Choose an Availability Zone
  map_public_ip_on_launch = false 
  tags = {
    Name = "com.div.proj.comp.vpc.public-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "com_div_proj_comp_vpc_private_subnet" {
  vpc_id     = aws_vpc.com_div_proj_comp_vpc.id
  cidr_block = "10.0.2.0/24"  # Define subnet CIDR block for private subnet
  availability_zone = "us-east-1b"  # Choose an Availability Zone
  tags = {
    Name = "com.div.proj.comp.vpc.private-subnet"
  }
}

# Create an Internet Gateway (for the public subnet)
resource "aws_internet_gateway" "com_div_proj_comp_vpc_igw" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
  tags = {
    Name = "com.div.proj.comp.vpc.InternetGateway"
  }
}

# Create a Route Table for the public subnet
resource "aws_route_table" "com_div_proj_comp_vpc_public_rt" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
  tags = {
    Name = "PublicRouteTable"
  }
}

# Create a route for the public route table to access the internet
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.com_div_proj_comp_vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.com_div_proj_comp_vpc_igw.id
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.com_div_proj_comp_vpc_public_subnet.id
  route_table_id = aws_route_table.com_div_proj_comp_vpc_public_rt.id
}

# Create a NAT Gateway for the private subnet to access the internet
resource "aws_eip" "nat_ip" {
  domain = vpc
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.com_div_proj_comp_vpc_public_subnet.id
  tags = {
    Name = "NatGateway"
  }
}

# Create a Route Table for the private subnet
resource "aws_route_table" "com_div_proj_comp_vpc_private_rt" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

# Create a route for the private route table to go through the NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.com_div_proj_comp_vpc_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.com_div_proj_comp_vpc_private_subnet.id
  route_table_id = aws_route_table.com_div_proj_comp_vpc_private_rt.id
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
}

# Create a security group for the public subnet
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
  description = "Security group for the public subnet"

  # Allow SSH and HTTP traffic to the public subnet
  egress {
    cidr_blocks = ["var.admin_public_ip"]
    description = "Only allow HTTPS traffic to go out"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [var.admin_public_ip]
    description = "Allow SSH access from admin public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [var.admin_public_ip]
    description = "Allow HTTP access from admin public IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  tags = {
    Name = "PublicSG"
  }
}

# Create a security group for the private subnet
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.com_div_proj_comp_vpc.id
  description = "Security group for the private subnet"

  # Allow all outbound traffic from the private subnet
  egress {
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow all traffic to go out"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  # Restrict inbound traffic (only allow private IP ranges, for example)
  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow all traffic from the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "PrivateSG"
  }
}

# Output the VPC ID for reference
output "vpc_id" {
  value = aws_vpc.com_div_proj_comp_vpc.id
}

# Output the public subnet ID
output "public_subnet_id" {
  value = aws_subnet.com_div_proj_comp_vpc_public_subnet.id
}

# Output the private subnet ID
output "private_subnet_id" {
  value = aws_subnet.com_div_proj_comp_vpc_private_subnet.id
}

# Output the public IP for the NAT Gateway
output "nat_gateway_ip" {
  value = aws_eip.nat_ip.public_ip
}
