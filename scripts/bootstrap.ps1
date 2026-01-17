# Wrapper script to run Terraform Bootstrap (S3 + DynamoDB + OIDC)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot
$BootstrapDir = Join-Path $ProjectRoot "infrastructure-live\bootstrap"

Write-Host "Initializing Bootstrap in: $BootstrapDir" -ForegroundColor Cyan
Set-Location $BootstrapDir

# Init
Write-Host "1. Running Terraform Init..." -ForegroundColor Cyan
terraform init
if ($LASTEXITCODE -ne 0) { Write-Error "Init failed!"; exit 1 }

# Apply
Write-Host "2. Running Terraform Apply..." -ForegroundColor Cyan
terraform apply -auto-approve

Write-Host "`n---------------------------------------------------" -ForegroundColor Green
Write-Host "Bootstrap Complete!" -ForegroundColor Green
Write-Host "IMPORTANT: Copy the 'github_actions_role_arn' output above" -ForegroundColor Yellow
Write-Host "and add it to your GitHub Repository Secrets as 'AWS_ROLE_ARN'." -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Green
