output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.vpc.public_subnets
}

output "database_subnet_group_name" {
  description = "데이터베이스 서브넷 그룹 이름"
  value       = module.vpc.database_subnet_group_name
}

output "database_subnets" {
  description = "데이터베이스 서브넷 ID 목록"
  value       = module.vpc.database_subnets
} 