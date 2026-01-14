# Infrastructure Live Implementation

This directory contains the "instantiation" of our infrastructure. It consumes the generic modules (from external repo) and applies specific configurations for each environment.

## 📂 Directory Structure

- **`main.tf`**: The primary entry point. It calls modules like `vpc`, `compute`, `iam` and passes in variables.
<!-- Trigger Test -->
- **`variables.tf`**: Declaration of input variables (e.g., region, instance_type).
- **`dev.tfvars`**: Values specific to the Development environment (e.g., smaller instances).
- **`prod.tfvars`**: Values specific to Production (e.g., larger instances, high availability).
- **`bootstrap/`**: Contains the Terraform configuration to creates the S3 Backend and DynamoDB table.

## 🌍 Workspaces

We use **Terraform Workspaces** to separate state files within the same S3 bucket:

| Environment | Workspace Name | Config File |
| :--- | :--- | :--- |
| **Development** | `dev` | `dev.tfvars` |
| **Production** | `prod` | `prod.tfvars` |

## 🛠 How to run locally (Debugging only)

**Note:** In normal operation, GitHub Actions handles this. Only run locally for debugging.

1.  **Initialize**:
    ```bash
    terraform init
    ```
2.  **Select Workspace**:
    ```bash
    terraform workspace select dev
    # OR create if missing: terraform workspace new dev
    ```
3.  **Plan**:
    ```bash
    terraform plan -var-file="dev.tfvars"
    ```
4.  **Apply**:
    ```bash
    terraform apply -var-file="dev.tfvars"
    ```
