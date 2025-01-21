# CodeBuild를 위한 IAM 역할 생성
resource "aws_iam_role" "cicd_service_role" {
  name = "cicd-service-rule"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# CodeBuild를 위한 기본 정책 연결
resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.cicd_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

# CodeBuild 프로젝트 생성
resource "aws_codebuild_project" "my_codebuild" {
  name         = "my-cicd-pipeline-CB"
  description  = "CodeBuild project for Docker build"
  service_role = aws_iam_role.cicd_service_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/leejoonyeob/minipunk"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode            = true  # Docker 빌드를 위해 필요

    environment_variable {
      name  = "DOCKER_IMAGE_NAME"
      value = "minipunk"
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "NO_CACHE"
  }
}