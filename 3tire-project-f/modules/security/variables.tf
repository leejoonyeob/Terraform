variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# 누락된 변수들
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "allowed_cidr" {
  description = "Allowed CIDR blocks for ALB ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}