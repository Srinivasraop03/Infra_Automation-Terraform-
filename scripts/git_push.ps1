param (
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot
Set-Location $ProjectRoot

# 1. Format
Write-Host "1. DRY RUN: Formatting Terraform code..." -ForegroundColor Cyan
terraform fmt -recursive
if ($LASTEXITCODE -ne 0) { Write-Error "Terraform Format failed!"; exit 1 }

# 2. Add
Write-Host "2. Adding all changes..." -ForegroundColor Cyan
git add .

# 3. Commit
$FinalMessage = $Message
$SkipCI = Read-Host "Skip CI/CD Trigger? (y/N)"
if ($SkipCI -eq 'y' -or $SkipCI -eq 'Y') {
    $FinalMessage = "$Message [skip ci]"
    Write-Host "Skipping CI build explicitly." -ForegroundColor Yellow
}

Write-Host "3. Committing with message: '$FinalMessage'..." -ForegroundColor Cyan
git commit -m "$FinalMessage"

# 4. Push
Write-Host "4. Pushing to origin main..." -ForegroundColor Cyan
git push origin main

Write-Host "Done! Code successfully pushed to GitHub." -ForegroundColor Green
