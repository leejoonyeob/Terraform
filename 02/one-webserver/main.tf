# AWS provider 선언
provider "aws" {
  region = "us-east-2"
}

# EC2 인스턴스를 위한 Security Group 생성
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_8080"
  }
}

# Security Group에 추가할 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "allow_http_8080" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# EC2 인스턴스 생성
resource "aws_instance" "example" {
  # AMI ID: Ubuntu 20.04 LTS
  ami                    = "ami-036841078a4b68e14"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data_replace_on_change = true
  user_data                   = <<-EOF
                #!/bin/bash
                echo "hello, world" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

  tags = {
    Name = "terraform-example"
  }
}