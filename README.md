# Enterprise Infrastructure Automation (Terraform)
![Build Status](https://github.com/Srinivasraop03/Infra_Automation-Terraform-/actions/workflows/deploy-live.yml/badge.svg)

This repository hosts a production-ready, modular Infrastructure as Code (IaC) solution for AWS, powered by **Terraform** and **GitHub Actions**. It implements enterprise best practices including state locking, environment isolation (Dev/Prod), and automated CI/CD pipelines.

---
<!-- Triggering pipeline test to verify DEV vs PROD isolation -->

## 🏗 Architecture & Design

### 1. Modular Design
- **Modules Registry**: Modules are now hosted in a separate repository [Infra_Terraform_Modules](https://github.com/Srinivasraop03/Infra_Terraform_Modules), allowing for versioning and reuse across projects.
- **`infrastructure-live/`**: The "Implementation" layer. This is where we call the modules and define environment-specific values (`dev.tfvars`, `prod.tfvars`).

### 2. Environment Isolation
We use **Terraform Workspaces** to maintain strict separation between environments within the same backend:
- **`dev` workspace**: Sandbox environment, auto-deployed from `main`.
- **`prod` workspace**: Production environment, deployed only from Tags with manual approval.

### 3. Backend Strategy
- **S3 Bucket**: Stores the Terraform state file (`terraform.tfstate`).
- **DynamoDB**: Provides state locking to prevent concurrent writes/corruptions.

---

## 🚀 CI/CD Pipelines (GitHub Actions)

This project uses an automated "Promote to Production" strategy.

| Environment | Trigger Event | Pipeline Action | Safety Mechanisms |
| :--- | :--- | :--- | :--- |
| **Development** | Push to `main` branch | Auto-deploys to `dev` workspace | Path filtering (only runs on infra changes) |
| **Production** | Push Git Tag (`v*`) | Deploys to `prod` workspace | **Manual Approval** required in GitHub Environments |
| **Destroy** | Manual Workflow Run | Destroys selected env | Requires user to type "YES" to confirm |

### Detailed Workflows

#### A. Deploying to Development
Simply push your code to the main branch.
```bash
git add .
git commit -m "feat: updated instance type"
git push origin main
# 🚀 GitHub Action triggers automatically and updates DEV.
```

#### B. Promoting to Production
When Dev is stable, create a release tag.
```bash
git tag v1.0.0
git push origin v1.0.0
# ✋ GitHub Action starts but PAUSES.
# 📧 Go to GitHub Actions UI -> "Review Deployments" -> Approve to deploy to PROD.
```

#### C. Destroying Infrastructure
1. Go to **Actions** tab.
2. Select **"Destroy Infrastructure"**.
3. Choose Environment (`dev` or `prod`).
4. Type **`YES`** in the confirmation box.
5. Click **Run**.

---

## 📂 Repository Structure

```text
├── .github/workflows/      # CI/CD Definitions
│   ├── bootstrap.yml       # Setup S3/OIDC (Layer 0)
│   ├── deploy-live.yml     # App Deploy (Layer 1)
│   └── destroy.yml         # App Destroy
├── bootstrap/              # Terraform for S3/OIDC
├── infrastructure-live/    # Terraform for App
├── scripts/                # Helper Scripts
└── README.md               # Documentation
```

---

## 🛠 Getting Started (First Time Setup)

If you are forking or setting this up from scratch:

### 1. Bootstrap Backend & OIDC (One-Time Setup)
We use a **GitHub Action** to bootstrap the account.
1. Go to **Settings > Secrets > Actions** and add temporary AWS Keys (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
2. Go to **Actions** tab -> Select **Bootstrap Backend**.
3. Click **Run Workflow** -> `apply`.
4. Wait for completion.
5. Copy the `github_actions_role_arn` from the logs.

### 2. Configure GitHub Secrets
Go to **Settings > Secrets and variables > Actions** and add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 3. Setup GitHub Environment (For Approval)
1. Go to **Settings > Environments**.
2. Create an environment named **`prod`**.
3. Enable **"Required Reviewers"** and add yourself.

---

## 📝 Configuration Files (`.tfvars`)

The infrastructure differences are controlled entirely by these files:

**`dev.tfvars`**
```hcl
environment = "dev"
instance_type = "t3.micro"
single_nat_gateway = true  # Save money
```

**`prod.tfvars`**
```hcl
environment = "prod"
instance_type = "m5.large"
single_nat_gateway = false # High Availability
```
