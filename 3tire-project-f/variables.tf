# 공통 변수
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# VPC 변수
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# Security 변수
variable "allowed_cidr" {
  description = "Allowed CIDR blocks for ALB ingress"
  type        = list(string)
}

# ALB 변수
variable "health_check_path" {
  description = "Health check path for target groups"
  type        = string
}

# EC2/ASG 변수
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-08970251d20e940b0" # Amazon Linux 2023 AMI (us-east-2)
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum size for ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum size for ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
}

# RDS 변수
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

# 태그
variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
}

variable "key_name" {
  description = "Name of the key pair to use for instances"
  type        = string
}