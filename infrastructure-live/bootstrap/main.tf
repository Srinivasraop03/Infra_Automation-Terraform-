terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Terraform State Bucket
# Uses your existing module to ensure standard tagging/encryption/versioning
module "tf_state_bucket" {
  source = "git::https://github.com/Srinivasraop03/Infra_Terraform_Modules.git//modules/aws/s3?ref=main"

  bucket_name        = "terraform-infra-state-bucket-srini" # Updated for uniqueness
  environment        = "global"
  versioning_enabled = true
}

# 2. DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-locks"
    Environment = "global"
  }
}

output "s3_bucket_name" {
  value = module.tf_state_bucket.bucket_id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

# 3. OIDC Provider for GitHub Actions
# Thumbprint list includes GitHub's certificates. 
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Known GitHub Actions thumbprints
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 4. IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # Allow deployments from main branch and tags in this specific repo
            "token.actions.githubusercontent.com:sub" : "repo:Srinivasraop03/Infra_Automation-Terraform-:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Grant AdministratorAccess to the Runner (or scope this down as needed)
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
  description = "Role ARN for GitHub Actions to use"
  value       = aws_iam_role.github_actions.arn
}

