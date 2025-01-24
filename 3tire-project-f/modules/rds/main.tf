module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.environment}-mysql"

  # 기본 엔진 설정
  engine               = "mysql"
  engine_version       = "8.0"
  family              = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = var.db_instance_class

  # 최소 저장소 설정
  allocated_storage     = 10    # 초기 10GB
  max_allocated_storage = 20    # 최대 20GB

  # 데이터베이스 기본 설정
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  # 단일 AZ 사용
  multi_az               = false

  # 네트워크 설정
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  # 백업 비활성화
  backup_retention_period = 0

  # 삭제 설정
  deletion_protection = false
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-db"
  allocated_storage    = var.allocated_storage
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.db_instance_class
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  port                = var.port
  skip_final_snapshot = true
  backup_retention_period = 0
  deletion_protection     = false
  multi_az               = false

  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.environment}-db"
  }
} 