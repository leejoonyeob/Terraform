# 최신 Amazon Linux 2023 AMI 가져오기
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.*-kernel-6.1-x86_64"]
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

# WEB Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.web_was_security_group_id]
    delete_on_termination      = true
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

# 패키지 설치
sudo yum -y install epel-release
sudo yum -y install httpd httpd-tools
sudo yum -y install mysql

# Apache 설정 디렉토리 생성 및 권한 설정
sudo mkdir -p /var/www/html
sudo chown -R ec2-user:apache /var/www/html
sudo chmod 2775 /var/www/html

# 기본 웹 페이지 생성
cat > /var/www/html/index.html << 'INNEREOF'
<!DOCTYPE html>
<html>
<head>
    <title>Hello, HTTP!</title>
    <meta charset="utf-8">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
        }
        h1 {
            font-size: 48px;
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Hello, HTTP!</h1>
</body>
</html>
INNEREOF

# 최종 권한 설정
sudo chown -R apache:apache /var/www/html/*
sudo chmod -R 644 /var/www/html/*
sudo chmod 755 /var/www/html

# 서비스 시작
sudo systemctl start httpd
sudo systemctl enable httpd

EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

# WAS Launch Template
resource "aws_launch_template" "was" {
  name_prefix   = "${var.environment}-was"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(templatefile("${path.module}/userdata_was.tpl", {
    db_endpoint = var.db_endpoint,
    db_username = var.db_username,
    db_password = var.db_password
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
    http_put_response_hop_limit = 1
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.web_was_security_group_id]
    delete_on_termination      = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

# WEB ASG
resource "aws_autoscaling_group" "web" {
  desired_capacity    = 1
  max_size           = 1
  min_size           = 1
  target_group_arns  = [var.web_target_group_arn]
  vpc_zone_identifier = var.public_subnet_ids

  # 인스턴스 수 강제 고정
  lifecycle {
    ignore_changes = [desired_capacity]
  }

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-web-asg"
    propagate_at_launch = true
  }
}

# WAS ASG
resource "aws_autoscaling_group" "was" {
  desired_capacity    = 1
  max_size           = 1
  min_size           = 1
  target_group_arns  = [var.was_target_group_arn]
  vpc_zone_identifier = var.public_subnet_ids

  health_check_type          = "ELB"
  health_check_grace_period  = 600

  # 인스턴스 교체 정책
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  launch_template {
    id      = aws_launch_template.was.id
    version = aws_launch_template.was.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-was-asg"
    propagate_at_launch = true
  }

  # 초기화 대기 시간 설정
  wait_for_capacity_timeout = "20m"

  # user-data 변경 시 인스턴스 교체
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
    }
  }
}

# IAM 역할 생성
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM 인스턴스 프로파일
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# RDS 접근 정책
resource "aws_iam_role_policy" "rds_access" {
  name = "${var.environment}-rds-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_basic" {
  name = "${var.environment}-ec2-basic"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# SSM 정책 수정
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
} 