variable "environment" {
  description = "환경 구분"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "웹 서버 보안 그룹 ID"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB 보안 그룹 ID"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "target_group_arns" {
  description = "ALB 타겟 그룹 ARN 목록"
  type        = list(string)
  default     = []
} 