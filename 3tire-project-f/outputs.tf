output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_connection_info" {
  value = "mysql -h ${module.rds.db_endpoint} -u ${var.db_username} -p"
  description = "Command to connect to RDS"
  sensitive = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}