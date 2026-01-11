# Infrastructure Automation (Terraform)

This repository contains the Infrastructure as Code (IaC) to provision and manage AWS resources using Terraform. It is designed with modularity, scalability, and enterprise best practices in mind.

## Repository Layout

*   **`infrastructure-live/`**
    *   Contains the "live" environment configurations (Workspaces for Dev, Stage, Prod).
    *   Includes `backend.tf` (state configuration) and `main.tf` (resource instantiation).
    *   **Note:** `*.tfvars` files are used for input values but sensitive secrets should be injected via CI/CD variables.
*   **`terraform-modules/`**
    *   Library of reusable Terraform modules (VPC, Compute, IAM, S3).
    *   Ensures consistent resource configuration across all environments.
*   **`scripts/`**
    *   Utility scripts for maintenance (e.g., S3 backup/cleanup, bootstrapping).
*   **`.github/workflows/`**
    *   CI/CD Pipelines for automated Provisioning and Destruction.

## Getting Started

### 1. Prerequisites
*   AWS CLI installed and configured.
*   Terraform v1.5+ installed.
*   Git Bash (or compatible shell).

### 2. Bootstrap State (One-Time Setup)
Before running Terraform, you must create the remote state bucket and locking table.
Run the included script:
```bash
./scripts/bootstrap.sh
```

### 3. Usage
**Plan Infrastructure:**
```bash
cd infrastructure-live
terraform init
terraform workspace new dev  # or select existing
terraform plan -var-file="dev.tfvars"
```

**Apply Infrastructure:**
```bash
terraform apply -var-file="dev.tfvars"
```

---

## CI/CD Workflows

This project includes GitHub Actions workflows for automated management.

### Provision Pipeline (`provision.yml`)
*   **Trigger:** Manual (Workflow Dispatch).
*   **Input:** Select Environment (dev/stage/prod).
*   **Action:** Runs `terraform plan` and `terraform apply`.

### Destroy Pipeline (`destroy.yml`)
*   **Trigger:** Manual.
*   **Input:** Environment + Confirmation text ("DESTROY").
*   **Action:** Tears down all infrastructure in the selected environment.

**Setup Required:**
Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to GitHub Repository Secrets.

---

## Enterprise Roadmap & Architecture Guide

To elevate this project to a fully enterprise-grade platform, the following standards are recommended:

### 1. Security & Authentication
*   **Current:** Long-lived AWS Access Keys.
*   **Target:** **OpenID Connect (OIDC)**. Eliminate keys by allowing GitHub Actions to assume a temporary IAM Role.

### 2. GitOps Workflow
*   **Current:** Manual Trigger.
*   **Target:** **Pull Request Automation**.
    *   **PR Open:** Auto-run `terraform plan`. Post results as a PR comment.
    *   **PR Merge:** Auto-run `terraform apply` to Dev/Stage.
    *   **Release Tag:** Trigger deployment to Production with manual approval gates.

### 3. State Isolation
*   **Current:** Terraform Workspaces (Shared `main.tf`).
*   **Target:** **Directory Isolation**.
    *   Split into `live/dev`, `live/prod` folders. This isolates failure domains (breaking Dev config won't break Prod).

### 4. Continuous Compliance
*   **Drift Detection:** Nightly scheduled cron jobs to detect manual changes in AWS.
*   **Static Analysis:** Integrate `tfsec` or `checkov` in CI to block insecure code (e.g., open security groups) before merge.
