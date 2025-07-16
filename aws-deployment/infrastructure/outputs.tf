###############################################################################
# Outputs                                                                      #
###############################################################################

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "lambda_security_group_id" {
  description = "Security group ID used for egress-only compute resources (Lambda, ECS, etc.)"
  value       = aws_security_group.egress_only.id
}

output "rds_security_group_id" {
  description = "Security group ID that allows inbound PostgreSQL from internal compute resources"
  value       = aws_security_group.rds.id
}