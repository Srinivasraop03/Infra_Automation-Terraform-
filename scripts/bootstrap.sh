#!/bin/bash
# Simple bootstrap script for Terraform State

BUCKET="terraform-infra-state-bucket-srini"
TABLE="terraform-locks"
REGION="us-east-1"

echo "1. Creating S3 Bucket..."
aws s3 mb "s3://$BUCKET" --region "$REGION" || echo "Bucket might already exist, continuing..."

echo "2. Enabling Versioning (Required for state safety)..."
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

echo "3. Enabling Encryption..."
aws s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "4. Blocking Public Access..."
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "5. Creating DynamoDB Lock Table..."
aws dynamodb create-table \
    --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION" || echo "Table might already exist, continuing..."

echo "Success! Infrastructure foundation is ready."
