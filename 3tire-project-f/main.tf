provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_name        = "${var.environment}-vpc"
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  allowed_cidr = var.allowed_cidr
  vpc_cidr    = var.vpc_cidr
}

module "alb" {
  source               = "./modules/alb"
  environment         = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  target_group_name    = "${var.environment}-tg"
  health_check_path    = var.health_check_path
}

module "asg" {
  source                    = "./modules/asg"
  environment              = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  web_was_security_group_id = module.security.web_was_sg_id
  web_target_group_arn      = module.alb.web_tg_arn
  was_target_group_arn      = module.alb.was_tg_arn
  instance_type            = var.instance_type
  ami_id                   = var.ami_id
  key_name                 = var.key_name
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  db_endpoint              = module.rds.db_endpoint
  db_username              = var.db_username
  db_password              = var.db_password
}

module "rds" {
  source = "./modules/rds"

  environment       = var.environment
  vpc_id           = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id = module.security.rds_security_group_id
  
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  db_instance_class = var.db_instance_class
} 