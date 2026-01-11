Run order and notes

 - Bootstrap first (no tfvars required):
   - cd bootstrap
   - terraform init
   - terraform plan
   - terraform apply
   - This creates the S3 bucket and DynamoDB table used for remote state locking.

 - Then the live infrastructure (after bootstrap completes):
   - cd ..
   - terraform init -reconfigure
   - Create workspaces as needed (e.g., `terraform workspace new dev`)
   - terraform plan -var-file="dev.tfvars"      # or prod.tfvars
   - terraform apply -var-file="dev.tfvars"

Important notes:
- The `bootstrap` module output `s3_bucket_name` now uses the S3 module's `bucket_id` output.
- `dev.tfvars` currently exposes SSH from `0.0.0.0/0` — only acceptable for short-lived testing. Restrict this before long-term use.
- The compute module currently consumes a single `subnet_id` (`module.vpc.private_subnet_ids[0]`). For HA, consider spreading instances across private subnets and AZs.
- Consider adding `aws_s3_bucket_public_access_block` and KMS encryption for state buckets if required by your security posture.
