# terraform & provider 설정
terraform {
   required_providers {
      aws = {
            source = "hashicorp/aws"
            version = "5.83.1"
      }
   }
}

# 작업 절차
# 0. 기본 인프라 구성
# 1. autoscaling group 생성
#   1) 보안그룹생성
#   2) 시작 템플릿 생성
#   3) autoscaling group 생성
# 2. ASG 생성
#   1) 보안그룹생성
#   2) LB target group 생성
#   3) LB 구성
#   4) LB listener 구성
#   5) LB listener rule 구성

# 0. 기본 인프라 구성 #
provider "aws" {
   region = var.region
}

data "aws_vpc" "default" {
   default = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default" {
   filter {
      name   = "vpc-id"
      values = [ data.aws_vpc.default.id ]
   }
}

# 1. ASG 생성 #
resource "aws_security_group" "myasg_sg" {
   name        = "myasg_sg"
   description = "Allow SSh,HTTP inbound traffic and all outbound traffic"
   vpc_id      = data.aws_vpc.default.id
   tags = {
      Name = "myasg_sg"
   }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
   security_group_id = aws_security_group.myasg_sg.id
   cidr_ipv4         = "0.0.0.0/0"
   from_port         = 22
   ip_protocol       = "tcp"
   to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
   security_group_id = aws_security_group.myasg_sg.id
   cidr_ipv4         = "0.0.0.0/0"
   from_port         = var.web_port
   ip_protocol       = "tcp"
   to_port           = var.web_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
   security_group_id = aws_security_group.myasg_sg.id
   cidr_ipv4         = "0.0.0.0/0"
   ip_protocol       = "-1"
}

data "aws_ami" "amazon_2023_ami" {
   most_recent      = true
   owners           = [ var.amazone ]

   filter {
      name   = "name"
      values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
   }

   filter {
      name   = "root-device-type"
      values = ["ebs"]
   }

   filter {
      name   = "virtualization-type"
      values = ["hvm"]
   }
}

# 템플릿 정의
resource "aws_launch_template" "myasg_sg_template" {
      name = "myasg_sg_template"
      image_id = data.aws_ami.amazon_2023_ami.id
      instance_type = "t2.micro"
      vpc_security_group_ids = [ aws_security_group.myasg_sg.id ]
      user_data = base64encode(<<-EOF
      #!/bin/bash
      yum -y install httpd mod_ssl
      echo "myWEB" > /var/www/html/index.html
      systemctl enable --now httpd
      EOF
      )

      lifecycle {
            create_before_destroy = true
      }
}

# 오토스케일링 그룹
resource "aws_autoscaling_group" "myasg" {
   name                      = "myasg"
   vpc_zone_identifier = data.aws_subnets.default.ids
   launch_template {
      id = aws_launch_template.myasg_sg_template.id
   }

   ################# 주의 #################
   # load_belancers
   target_group_arns = [ aws_lb_target_group.mylb_tg.arn ]
   depends_on = [ aws_lb_target_group.mylb_tg ]

   min_size                  = var.min_instance
   max_size                  = var.max_instance

   tag {
      key = "lorem"
      value = "myASG"
      propagate_at_launch = true
   }
}

# ALB 생성
resource "aws_lb_target_group" "mylb_tg" {
  name        = "mylb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myasg_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "mylb_listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

      fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "mylb_listener_role" {
  listener_arn = aws_lb_listener.mylb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mylb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}
