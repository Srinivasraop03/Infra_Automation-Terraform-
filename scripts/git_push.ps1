param (
    [Parameter(Mandatory=$true)]
    [string]$Message
)

# Navigate to the script's root (assuming script is in /scripts and we want project root)
$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot
Set-Location $ProjectRoot

Write-Host "1. Adding all changes from project root..." -ForegroundColor Cyan
git add .

Write-Host "2. Committing with message: '$Message'..." -ForegroundColor Cyan
git commit -m "$Message"

Write-Host "3. Pushing to origin main..." -ForegroundColor Cyan
git push origin main

Write-Host "Done! Code successfully pushed to GitHub." -ForegroundColor Green
