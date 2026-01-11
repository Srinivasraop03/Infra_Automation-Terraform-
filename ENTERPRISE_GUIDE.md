# Enterprise Infrastructure Automation Guide

This guide outlines how to elevate your Terraform project from a personal setup to an **Enterprise-Grade** automation platform.

## 1. Security & Authentication (OIDC)
**Current:** Using AWS Access Keys (`AWS_ACCESS_KEY_ID`) in GitHub Secrets.
**Risk:** Long-lived keys can be leaked. Key rotation is manual.
**Enterprise Standard:** **OpenID Connect (OIDC)**.
- GitHub Actions "assumes" an IAM Role temporarily.
- No permanent credentials stored in GitHub.
- Detailed audit logs in CloudTrail show "GitHubAction" as the source.

## 2. Infrastructure as Code (IaC) Workflow (GitOps)
**Current:** Manual "Workflow Dispatch" buttons to deploy.
**Enterprise Standard:** **Pull Request Driven Workflow**.
- **On Pull Request:**
  - Auto-run `terraform fmt`, `terraform validate`, `tflint`.
  - Auto-run `terraform plan`.
  - **Bot Comment:** The Plan output is automatically posted as a comment on the PR for review.
  - Security Scanning: Run `tfsec` or `checkov` to block insecure resources (e.g. open S3 buckets).
- **On Merge to Main (Dev/Stage):**
  - Automatically `terraform apply` to Dev/Stage.
- **On Release/Tag (Prod):**
  - Deployment to Production is triggered by creating a Release or Tag (e.g., `v1.0.0`).
  - **Manual Approval Gate:** Use GitHub Environments to require a human "Approve" button before the Production apply runs.

## 3. State Management & Isolation
**Current:** Terraform Workspaces (`dev`, `stage`, `prod` sharing one config).
**Enterprise Standard:** **Directory Isolation**.
- Workspaces share the same `main.tf`. If you break the config, you break ALL environments.
- **Best Practice:** Separate directories:
  ```text
  infrastructure-live/
  ├── dev/
  │   ├── main.tf
  │   └── backend.tf
  ├── prod/
  │   ├── main.tf
  │   └── backend.tf
  ```
- This allows `dev` to use a different version of a module than `prod`.

## 4. Drift Detection
**Problem:** Someone changes a Security Group manually in the AWS Console. Terraform doesn't know.
**Enterprise Standard:** **Scheduled Nightly Plans**.
- A GitHub Action runs every night (`cron`).
- It runs `terraform plan -detailed-exitcode`.
- If changes are detected (Drift), it sends an alert to Slack/Teams.

## 5. Artifact Handling & Tooling
- **Pre-commit Hooks:** Force formatting and validation on your laptop before you even commit.
- **Cost Estimation:** Integrate `infracost` in the PR to see "$$ Impact: +$50/month" on the PR comment.

---

## Recommended Roadmap for You

1.  **Phase 1 (Immediate):** Push current Workflows & Re-bootstrap S3 (Fix the foundation).
2.  **Phase 2 (Security):** Configure AWS OIDC Role and remove Access Keys.
3.  **Phase 3 (Automation):** Convert "Provision" pipeline to run automatically on PRs (Plan) and Merges (Apply).
4.  **Phase 4 (Quality):** Add `tfsec` scanning to the pipeline.
