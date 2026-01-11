Repository layout

- `infrastructure-live/` — Environment stacks. Contains `backend.tf`, `main.tf`, environment `*.tfvars`, and `bootstrap/` which creates the remote state bucket + lock table.
- `terraform-modules/` — Reusable Terraform modules (aws/vpc, aws/compute, aws/s3, aws/iam-roles).

Git ignore policy

- The repository uses a single root `.gitignore` to provide consistent ignore rules for contributors.
- We intentionally TRACK `dev.tfvars` and `prod.tfvars` in this repo for convenience. Do not commit secrets; if any `*.tfvars` contain secrets, add them to the repo-level `.gitignore` or move secrets to your secret manager.
- Commit `.terraform.lock.hcl` for each stack/workspace to pin provider checksums.

Usage notes

1. Bootstrap remote state (creates state S3 bucket and DynamoDB lock table):

```bash
cd infrastructure-live/bootstrap
terraform init
terraform apply -var-file="../dev.tfvars" # or prod.tfvars
```

2. Initialize the live stack (after bootstrap completes):

```bash
cd ..
terraform init
terraform apply -var-file="dev.tfvars" # or prod.tfvars
```

Why I removed `terraform-modules/.gitignore`

- The module-level `.gitignore` duplicated entries and could cause inconsistent behavior for contributors.
- If you intend to publish `terraform-modules/` as a standalone module repo, you can add a minimal `.gitignore` there again (only for module-specific ignores). For a single-repo workflow it's cleaner to have one root ignore file.

If you want, I can also:
- Add a `.gitattributes` and example `LICENSE`.
- Reintroduce a minimal module `.gitignore` if you plan to publish modules separately.
