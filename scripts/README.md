# Helper Scripts

This directory contains utility scripts to automate common setup and maintenance tasks.

## 1. Bootstrap (`bootstrap.ps1`)
**OS**: Windows (PowerShell)
**Purpose**: Easy wrapper to deploy the Bootstrap infrastructure (S3, DynamoDB, OIDC).

**Usage**:
```powershell
./scripts/bootstrap.ps1
```

## 2. Git Push Helper (`git_push.ps1`)
**OS**: Windows (PowerShell)
**Purpose**: Formats code and pushes to GitHub.

**What it does**:
- Runs `terraform fmt -recursive` to clean up code.
- Commits with your message.
- Pushes to `origin main`.

**Usage**:
```powershell
./scripts/git_push.ps1 "your commit message"
```

## 3. Clean S3 State Bucket (`empty_delete_s3_bucket.ps1`)
**OS**: Windows (PowerShell)
**Purpose**: One-time setup script to initialize the Terraform backend.

**What it does**:
- Creates an AWS S3 Bucket (for storing `terraform.tfstate`).
- Generates a `backend.tf` file (if needed).

**Usage**:
```powershell
./bootstrap.ps1
```

## 2. Git Push Helper (`git_push.sh`)
**OS**: Linux / Git Bash
**Purpose**: Simplifies the git commit and push workflow.

**What it does**:
- Adds all changes (`git add .`).
- Commits with your provided message.
- Pushes to `origin main`.

**Usage**:
```bash
./scripts/git_push.sh "your commit message"
```
