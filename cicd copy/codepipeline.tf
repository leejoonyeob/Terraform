# CodePipeline을 위한 S3 버킷 생성
resource "aws_s3_bucket" "artifact_store" {
  bucket = "my-pipeline-artifact-store-${data.aws_caller_identity.current.account_id}"
}

# S3 버킷 버전 관리 활성화
resource "aws_s3_bucket_versioning" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CodePipeline IAM 역할
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# CodePipeline IAM 정책
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-service-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "codecommit:*",
          "codebuild:*",
          "elasticbeanstalk:*",
          "iam:PassRole",
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      }
    ]
  })
}

# GitHub 연결을 위한 CodeStar connection
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# CodePipeline 생성
resource "aws_codepipeline" "pipeline" {
  name     = "my-pipeline-CP"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  # Source 스테이지
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "leejoonyeob/minipunk"
        BranchName       = "main"
      }
    }
  }

  # Build 스테이지
  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      region          = "ap-northeast-2"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.my_codebuild.name
      }
    }
  }

  # Deploy 스테이지
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      region          = "ap-northeast-2"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.myEB.name
        EnvironmentName = aws_elastic_beanstalk_environment.env.name
      }
    }
  }
}

# 현재 AWS 계정 ID를 가져오기 위한 데이터 소스
data "aws_caller_identity" "current" {} 