output "vpc_id" {
  value = aws_vpc.myVPC.id
  description = "The ID of the VPC"
}

output "ec2_instance_1_id" {
  value = aws_instance.MyEC21.id
  description = "The ID of EC2 instance 1"
}

output "ec2_instance_2_id" {
  value = aws_instance.MyEC22.id
  description = "The ID of EC2 instance 2"
}

output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
  description = "The DNS name of the ALB"
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.myalb-tg.arn
  description = "The ARN of the ALB target group"
}
