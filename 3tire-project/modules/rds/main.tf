module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.environment}-mysql"

  # 기본 엔진 설정
  engine               = "mysql"
  engine_version       = "8.0"
  family              = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = var.instance_class

  # 최소 저장소 설정
  allocated_storage     = 10    # 초기 10GB
  max_allocated_storage = 20    # 최대 20GB

  # 데이터베이스 기본 설정
  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 3306

  # 단일 AZ 사용
  multi_az               = false

  # 네트워크 설정
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [var.database_security_group_id]

  # 백업 비활성화
  backup_retention_period = 0

  # 삭제 설정
  deletion_protection = false
  skip_final_snapshot = true
} 