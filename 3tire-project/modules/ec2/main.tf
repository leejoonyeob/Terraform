# HTTP 서버용 ASG
module "asg_http" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.0"

  name = "${var.environment}-http-asg"

  min_size                  = 1
  max_size                  = 1
  desired_capacity         = 1
  vpc_zone_identifier      = var.private_subnet_ids
  target_group_arns        = [module.alb.target_group_arns[0]]
  health_check_type       = "ELB"
  health_check_grace_period = 300

  launch_template_name   = "${var.environment}-http-lt"
  image_id              = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [var.web_security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from HTTP Server</h1>" > /var/www/html/index.html
              EOF
  )
}

# PHP 서버용 ASG
module "asg_php" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.0"

  name = "${var.environment}-php-asg"

  min_size                  = 1
  max_size                  = 1
  desired_capacity         = 1
  vpc_zone_identifier      = var.private_subnet_ids
  target_group_arns        = [module.alb.target_group_arns[1]]
  health_check_type       = "ELB"
  health_check_grace_period = 300

  launch_template_name   = "${var.environment}-php-lt"
  image_id              = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [var.web_security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Apache와 PHP 설치
              yum update -y
              yum install -y httpd php
              
              # PHP 테스트 페이지 생성
              echo "<?php phpinfo(); ?>" > /var/www/html/index.php
              
              # Apache 시작
              systemctl start httpd
              systemctl enable httpd
              EOF
  )
}

# ALB 설정
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.environment}-alb"

  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets           = var.public_subnet_ids
  security_groups    = [var.alb_security_group_id]

  target_groups = [
    {
      name             = "${var.environment}-http-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path               = "/index.html"
        port               = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
      }
    },
    {
      name             = "${var.environment}-php-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path               = "/index.php"
        port               = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        matcher            = "200,302,404"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority               = 1
      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        path_patterns = ["/index.php", "*.php"]
      }]
    }
  ]
} 