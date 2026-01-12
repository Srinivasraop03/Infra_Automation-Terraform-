environment        = "prod"
vpc_cidr           = "10.1.0.0/16"
azs_count          = 2
single_nat_gateway = true # Save EIPs and money

instance_count    = 1
instance_type     = "t3.micro"
allowed_ssh_cidrs = ["10.0.0.0/8"] # Restricted for Prod

bucket_name = "my-app-unique-bucket-name-prod"
