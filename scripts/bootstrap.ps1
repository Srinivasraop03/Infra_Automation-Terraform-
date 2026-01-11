# Optimization for local execution: Disable EC2 metadata lookup to prevent timeouts
$env:AWS_EC2_METADATA_DISABLED = "true"
# Disable AWS CLI pager to prevent output buffering/hanging
$env:AWS_PAGER = ""

$BUCKET = "terraform-infra-state-bucket-srini"
$TABLE = "terraform-locks"
$REGION = "us-east-1"

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Initializing Infrastructure Bootstrap..." -ForegroundColor Cyan

# Check AWS Identity
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Checking AWS identity..."
aws sts get-caller-identity --query "Arn" --output text
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: efficient AWS credentials not found. Please run 'aws configure' or set env vars." -ForegroundColor Red
    exit 1
}

# 1. S3 Bucket
Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] 1. Checking S3 Bucket '$BUCKET'..."
aws s3api head-bucket --bucket "$BUCKET" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Creating Bucket..." -ForegroundColor Yellow
    aws s3 mb "s3://$BUCKET" --region "$REGION"
} else {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Bucket already exists." -ForegroundColor Green
}

# 2. Versioning
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Enabling Versioning..."
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

# 3. Encryption
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Enabling Encryption..."
aws s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration '{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\": {\"SSEAlgorithm\": \"AES256\"}}]}'

# 4. Public Access Block
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Blocking Public Access..."
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5. DynamoDB
Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] 2. Checking DynamoDB Table '$TABLE'..."
aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Creating Lock Table..." -ForegroundColor Yellow
    aws dynamodb create-table `
        --table-name "$TABLE" `
        --attribute-definitions AttributeName=LockID,AttributeType=S `
        --key-schema AttributeName=LockID,KeyType=HASH `
        --billing-mode PAY_PER_REQUEST `
        --region "$REGION"
} else {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Table already exists." -ForegroundColor Green
}

Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Success! S3 Backend resources are ready." -ForegroundColor Cyan
