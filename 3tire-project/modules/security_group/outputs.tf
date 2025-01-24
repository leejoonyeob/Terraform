output "web_sg_id" {
  description = "웹 서버 보안 그룹 ID"
  value       = module.web_sg.security_group_id
}

output "alb_sg_id" {
  description = "ALB 보안 그룹 ID"
  value       = module.alb_sg.security_group_id
}

output "db_sg_id" {
  description = "데이터베이스 보안 그룹 ID"
  value       = module.db_sg.security_group_id
} 