module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NAT Gateway 설정 (private subnet의 인터넷 접근용)
  enable_nat_gateway = true
  single_nat_gateway = true

  # DNS 설정
  enable_dns_hostnames = true
  enable_dns_support   = true

  # 퍼블릭 서브넷 자동 IP 할당
  map_public_ip_on_launch = true

  # 서브넷 태그 추가
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = var.tags
} 