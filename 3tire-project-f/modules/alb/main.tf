resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.target_group_name}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = var.health_check_path
  }
}

resource "aws_lb_target_group" "was" {
  name     = "${var.target_group_name}-was"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    timeout             = 10
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-399"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  # 등록 해제 지연 시간
  deregistration_delay = 300
  
  # 느린 시작 모드
  slow_start = 300

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener_rule" "php" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was.arn
  }

  condition {
    path_pattern {
      values = ["*.php", "/*.php", "/index.php", "/index.php/*"]
    }
  }
}

resource "aws_lb_listener_rule" "health" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was.arn
  }

  condition {
    path_pattern {
      values = ["/health", "/health.php"]
    }
  }
} 