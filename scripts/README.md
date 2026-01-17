# Helper Scripts

This directory contains utility scripts to automate common setup and maintenance tasks.

## 1. Bootstrap (`bootstrap.ps1`)
**OS**: Windows (PowerShell)
**Purpose**: One-time setup script to initialize the Terraform backend.

**What it does**:
- Creates an AWS S3 Bucket (for storing `terraform.tfstate`).
- Enables Versioning and Encryption on the bucket.
- Creates a DynamoDB Table (for State Locking).
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
