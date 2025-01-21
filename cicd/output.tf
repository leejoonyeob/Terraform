output "elastic_beanstalk_url" {
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
  description = "Elastic Beanstalk 환경의 URL"
}

output "codepipeline_name" {
  value       = aws_codepipeline.pipeline.name
  description = "CodePipeline 이름"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}