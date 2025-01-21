# Elastic Beanstalk IAM Role
resource "aws_iam_role" "elasticbeanstalk_service_role" {
  name = "elasticbeanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })
}

# Elastic Beanstalk Service Role Policy Attachments
resource "aws_iam_role_policy_attachment" "elasticbeanstalk_service" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_enhanced_health" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# EC2 Instance Profile for Elastic Beanstalk
resource "aws_iam_instance_profile" "elasticbeanstalk_ec2" {
  name = "elasticbeanstalk-ec2-profile"
  role = aws_iam_role.elasticbeanstalk_ec2_role.name
}

resource "aws_iam_role" "elasticbeanstalk_ec2_role" {
  name = "elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# EC2 Role Policy Attachments
resource "aws_iam_role_policy_attachment" "elasticbeanstalk_web_tier" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_multicontainer_docker" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}