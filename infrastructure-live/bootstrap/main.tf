terraform {
  required_version = "= 1.14.3"
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
  source = "../../terraform-modules/modules/aws/s3"

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
