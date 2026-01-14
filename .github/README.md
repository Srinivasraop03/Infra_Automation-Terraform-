# GitHub Actions CI/CD Workflows

This directory contains the automation logic for deploying and managing the infrastructure.

## Workflows

### 1. Deploy Live Infrastructure (`deploy-live.yml`)
**Trigger**: 
- Push to `main` -> Deploys to **DEV**.
- Push Tag `v*` -> Deploys to **PROD** (Requires Approval).

**Job Flow**:
1.  **Setup**: Determines the target environment (`dev` vs `prod`) based on the trigger (branch vs tag).
2.  **Plan**: Runs `terraform plan` and saves the output artifact.
3.  **Apply**: 
    - For **Dev**: Runs immediately.
    - For **Prod**: Pauses for Manual Approval in GitHub Environments, then runs `terraform apply`.

### 2. Manual Destroy (`destroy.yml`)
**Trigger**: Manual "Workflow Dispatch" only.
**Purpose**: Emergency cleanup or decommissioning environments.
**Safety**: Requires user to type "YES" explicitly in the input.

## Secrets Required
The following secrets must be configured in the Repository Settings:

| Secret Name | Description |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | AWS Credentials with permissions to manage resources (EC2, VPC, IAM, S3, DynamoDB) |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key |

## Environment Configuration
You must configure a **GitHub Environment** named `prod` in settings:
- Enable **"Required Reviewers"** and add the team leads to prevent accidental productions deployments.
