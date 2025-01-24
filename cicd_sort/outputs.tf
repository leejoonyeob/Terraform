output "elastic_beanstalk_url" {
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
  description = "Elastic Beanstalk Environment URL"
}

output "codepipeline_name" {
  value       = aws_codepipeline.app.name
  description = "CodePipeline Name"
} 