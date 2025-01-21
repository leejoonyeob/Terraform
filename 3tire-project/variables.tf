variable "database_password" {
  description = "RDS 관리자 비밀번호"
  type        = string
}

variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "availability_zones" {
  description = "사용할 가용영역 목록"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "environment" {
  description = "환경 구분"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
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

variable "instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
}

variable "database_subnet_cidrs" {
  description = "데이터베이스 서브넷 CIDR 블록 목록"
  type        = list(string)
}