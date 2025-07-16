###############################################################################
# VPC & Networking                                                             #
###############################################################################

# Get a list of availability zones in the chosen region so we can spread subnets
# across at most 3 zones (good enough for most workloads & free tier eligible)
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Derive /24 sub-CIDRs from the main VPC CIDR. The math keeps room for future
  # growth while still being deterministic.
  private_subnets = [for idx, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, idx)]        # 10.0.0.0/24, 10.0.1.0/24 …
  public_subnets  = [for idx, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, 100 + idx)]  # 10.0.100.0/24, 10.0.101.0/24 …
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "jargon-ai-${var.environment}"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  # Single NAT is free-tier friendly; flip to false for multi-AZ resilience
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}