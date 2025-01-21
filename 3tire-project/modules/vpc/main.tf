module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  create_database_subnet_group = true
  database_subnet_group_name   = "${var.environment}-db-subnet-group"
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = var.tags
} 