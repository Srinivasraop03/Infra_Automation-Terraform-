environment        = "dev"
vpc_cidr           = "10.0.0.0/16"
azs_count          = 2
single_nat_gateway = true

instance_count    = 1
instance_type     = "t3.micro"
allowed_ssh_cidrs = ["0.0.0.0/0"] # Open for dev testing

bucket_name = "my-app-unique-bucket-name-dev"
