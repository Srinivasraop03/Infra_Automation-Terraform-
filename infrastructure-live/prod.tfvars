environment        = "prod"
vpc_cidr           = "10.1.0.0/16"
azs_count          = 3
single_nat_gateway = false # High Availability for Prod

instance_count    = 2
instance_type     = "t3.medium"
allowed_ssh_cidrs = ["10.0.0.0/8"] # Restricted for Prod

bucket_name       = "my-app-unique-bucket-name"
