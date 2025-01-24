output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "web_was_sg_id" {
  value = aws_security_group.web_was.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}