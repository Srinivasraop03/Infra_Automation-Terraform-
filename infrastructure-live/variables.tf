variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

# --- VPC Variables ---
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs_count" {
  description = "Number of Availability Zones"
  type        = number
}

variable "single_nat_gateway" {
  description = "Use strict single NAT gateway (true for dev, false for prod)"
  type        = bool
}

# --- Compute Variables ---
variable "cluster_name" {
  description = "Name of the app cluster"
  type        = string
  default     = "my-app"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH"
  type        = list(string)
}

# --- S3 Variables ---
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
