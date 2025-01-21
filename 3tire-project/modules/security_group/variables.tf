variable "environment" {
  description = "환경 구분 (예: production, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
} 