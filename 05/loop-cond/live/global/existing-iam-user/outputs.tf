
output "all_users" {
  value = values(aws_iam_user.createuser)[*].arn
}
