environment        = "stage"
vpc_cidr           = "10.2.0.0/16"
azs_count          = 2
single_nat_gateway = true

instance_count    = 1
instance_type     = "t3.small"

# Replace with your admin IPs for SSH access to stage
allowed_ssh_cidrs = ["203.0.113.5/32"]

# Bucket name for stage (adjust if needed)
bucket_name = "my-app-unique-bucket-name-stage"
