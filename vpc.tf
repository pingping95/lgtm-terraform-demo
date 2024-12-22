# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.prefix
  cidr = var.vpc.cidr

  # Availability Zones and Subnets
  azs             = var.vpc.azs
  public_subnets  = var.vpc.public_subnets
  private_subnets = var.vpc.private_subnets

  # NAT Gateway Configuration
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # VPN Gateway
  enable_vpn_gateway = true

  # Subnet Tags for AWS Load Balancer Controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    Name                     = "${var.prefix}-public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"         = var.prefix
    Name                             = "${var.prefix}-private"
  }

  # VPC Tags
  tags = {
    Name        = var.prefix
    Environment = var.environment
    Terraform   = "true"
  }
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for NAT gateway"
  value       = module.vpc.nat_public_ips
}