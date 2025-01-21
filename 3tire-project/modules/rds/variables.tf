variable "environment" {
  description = "환경 구분"
  type        = string
}

variable "instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
}

variable "database_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "database_username" {
  description = "데이터베이스 관리자 사용자명"
  type        = string
}

variable "database_password" {
  description = "데이터베이스 관리자 비밀번호"
  type        = string
}

variable "database_subnet_group_name" {
  description = "데이터베이스 서브넷 그룹 이름"
  type        = string
}

variable "database_security_group_id" {
  description = "데이터베이스 보안 그룹 ID"
  type        = string
} 