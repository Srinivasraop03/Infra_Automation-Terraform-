# AWS S3 Module

This module creates an S3 bucket with configurable versioning and default server-side encryption (AES256).

## Usage

```hcl
module "s3" {
  source = "../terraform-modules/modules/aws/s3"

  bucket_name        = "my-app-data-dev"
  environment        = "dev"
  versioning_enabled = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket_name` | Name of the S3 bucket | `string` | n/a | yes |
| `environment` | Environment name (e.g. dev, prod) | `string` | n/a | yes |
| `versioning_enabled` | Enable versioning for the bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The name of the bucket |
| `bucket_arn` | The ARN of the bucket |
| `bucket_domain_name` | The bucket domain name |
