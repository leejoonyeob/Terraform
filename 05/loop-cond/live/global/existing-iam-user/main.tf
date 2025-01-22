terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "createuser" {
  for_each = toset(var.usernames)    # (set => each.value), (map => each.key, each.value)
  name     = each.value
}
