# AWS Service Account for Terraform
resource "aws_iam_user" "terraform_service_account" {
  name = "terraform-migration-service-account"
  path = "/service-accounts/"
  tags = {
    Description = "Service account for running Terraform migrations"
  }
}

# AWS Service Account Access Key
resource "aws_iam_access_key" "terraform_service_account" {
  user = aws_iam_user.terraform_service_account.name
}

# AWS Service Account Policy
resource "aws_iam_user_policy" "terraform_service_account" {
  name = "terraform-migration-policy"
  user = aws_iam_user.terraform_service_account.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "directconnect:*",
          "ec2-transitgateway:*",
          "s3:*",
          "iam:GetUser",
          "iam:ListUserPolicies",
          "iam:ListAttachedUserPolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

# AWS Group for Cloud Engineers
resource "aws_iam_group" "cloud_engineers" {
  name = "cloud-engineers"
  path = "/groups/"
}

# AWS User for Cloud Engineer
resource "aws_iam_user" "cloud_engineer" {
  name = "cloudengineer"
  path = "/users/"
  tags = {
    Email = "cloudengineer@random-company.io"
  }
}

# AWS User Login Profile
resource "aws_iam_user_login_profile" "cloud_engineer" {
  user    = aws_iam_user.cloud_engineer.name
  pgp_key = "keybase:cloudengineer"  # Replace with actual PGP key
}

# AWS User Group Membership
resource "aws_iam_user_group_membership" "cloud_engineer" {
  user = aws_iam_user.cloud_engineer.name
  groups = [aws_iam_group.cloud_engineers.name]
}

# AWS Group Policy
resource "aws_iam_group_policy" "cloud_engineers" {
  name  = "cloud-engineers-policy"
  group = aws_iam_group.cloud_engineers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "directconnect:*",
          "ec2-transitgateway:*",
          "s3:*",
          "iam:GetUser",
          "iam:ListUserPolicies",
          "iam:ListAttachedUserPolicies",
          "iam:PassRole",
          "iam:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Outputs
output "terraform_service_account_access_key" {
  value     = aws_iam_access_key.terraform_service_account.id
  sensitive = true
}

output "terraform_service_account_secret_key" {
  value     = aws_iam_access_key.terraform_service_account.ses_smtp_password_v4
  sensitive = true
}

output "cloud_engineer_password" {
  value     = aws_iam_user_login_profile.cloud_engineer.password
  sensitive = true
} 