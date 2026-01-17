# Helper Scripts

This directory contains utility scripts to automate common setup and maintenance tasks.

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
