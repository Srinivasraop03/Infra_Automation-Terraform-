$BUCKET = "terraform-infra-state-bucket-srini"
$TABLE = "terraform-locks"
$REGION = "us-east-1"

Write-Host "1. Creating S3 Bucket..."
aws s3 mb "s3://$BUCKET" --region "$REGION"
if ($LASTEXITCODE -ne 0) { Write-Host "Bucket might already exist or error occurred." }

Write-Host "2. Enabling Versioning..."
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

Write-Host "3. Enabling Encryption..."
aws s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

Write-Host "4. Blocking Public Access..."
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

Write-Host "5. Creating DynamoDB Lock Table..."
aws dynamodb create-table `
    --table-name "$TABLE" `
    --attribute-definitions AttributeName=LockID, AttributeType=S `
    --key-schema AttributeName=LockID, KeyType=HASH `
    --billing-mode PAY_PER_REQUEST `
    --region "$REGION"
if ($LASTEXITCODE -ne 0) { Write-Host "Table might already exist or error occurred." }

Write-Host "Success! Infrastructure foundation is ready."
