provider aws{
  region = "us-east-1"
}


resource "aws_instance" "example" {
  ami           = "ami-0b0ea68c435eb488d"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash

              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable --now httpd
              echo "Hello, World from ${hostname}" > /var/www/html/index.html
              EOF
}