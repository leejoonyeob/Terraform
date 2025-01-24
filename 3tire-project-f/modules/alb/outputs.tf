 output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "web_tg_arn" {
  value = aws_lb_target_group.web.arn
}

output "was_tg_arn" {
  value = aws_lb_target_group.was.arn
}