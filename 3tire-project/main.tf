provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  environment          = var.environment
  tags                 = var.tags
}

module "security_groups" {
  source = "./modules/security_group"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"

  environment           = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnets
  public_subnet_ids    = module.vpc.public_subnets
  web_security_group_id = module.security_groups.web_sg_id
  alb_security_group_id = module.security_groups.alb_sg_id
  ami_id               = var.ami_id
  instance_type        = var.instance_type
}

module "rds" {
  source = "./modules/rds"

  environment                 = var.environment
  instance_class             = var.instance_class
  database_name              = var.database_name
  database_username          = var.database_username
  database_password          = var.database_password
  database_subnet_group_name = module.vpc.database_subnet_group_name
  database_security_group_id = module.security_groups.db_sg_id
} 