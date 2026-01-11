terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  backend "s3" {
    # Replace this with the bucket name output from the bootstrap step
    bucket = "terraform-infra-state-bucket-srini"
    key    = "infrastructure-live/terraform.tfstate"
    region = "us-east-1"

    # DynamoDB table for locking
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
