provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# 1. NETWORKING (VPC)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "git::https://github.com/Srinivasraop03/Infra_Terraform_Modules.git//modules/aws/vpc?ref=main"

  vpc_name    = "${var.cluster_name}-vpc"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs_count   = var.azs_count

  # Dynamic Subnet Calculation based on CIDR
  public_subnet_cidrs  = [for i in range(var.azs_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.azs_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway # If not single, do one per AZ (HA)
}

# ------------------------------------------------------------------------------
# 2. IAM & SECURITY
# ------------------------------------------------------------------------------
module "iam" {
  source = "git::https://github.com/Srinivasraop03/Infra_Terraform_Modules.git//modules/aws/iam-roles?ref=main"

  cluster_name            = var.cluster_name
  environment             = var.environment
  role_type               = "ec2"
  create_instance_profile = true
}

# ------------------------------------------------------------------------------
# 3. COMPUTE (EC2)
# ------------------------------------------------------------------------------
module "compute" {
  source = "git::https://github.com/Srinivasraop03/Infra_Terraform_Modules.git//modules/aws/compute?ref=main"

  cluster_name = var.cluster_name
  environment  = var.environment
  node_type    = "worker"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0] # Note: Limitation of existing module (one subnet)

  instance_type  = var.instance_type
  instance_count = var.instance_count

  create_security_group   = true
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidrs

  iam_instance_profile = module.iam.instance_profile_name
}


