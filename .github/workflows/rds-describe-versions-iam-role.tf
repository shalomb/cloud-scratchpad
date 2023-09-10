terraform {
  required_version = ">= 1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  github_repo = "shalomb/cloud-scratchpad"
}

# Get the latest TLS cert from GitHub to authenticate their requests
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC Provider in the AWS Account
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Create an IAM policy
resource "aws_iam_policy" "allow_describe_rds_versions" {
  name = "AllowDescribeDBEngineVersions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDescribeDBEngineVersions"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBEngineVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws
# https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/roles/details/Ansible-Github-Metabase-Read?section=permissions

# Create an IAM role
resource "aws_iam_role" "rds_versions_describer" {
  name = "RDSDBVersionDescriber"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:shalomb/cloud-scratchpad:ref:refs/heads/*"
          }
        }
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "rds_versions_describer_role_policy_attachment" {
  name       = "Policy Attachement"
  policy_arn = aws_iam_policy.allow_describe_rds_versions.arn
  roles = [
    aws_iam_role.rds_versions_describer.name
  ]
}
