terraform {
  backend "s3" {
    # Replace this with the bucket name output from the setup step
    bucket         = "infrastructure-automation-state-store-srini-01"
    key            = "infrastructure-live/terraform.tfstate"
    region         = "us-east-1"
    
    # DynamoDB table for locking
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
