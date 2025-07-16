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

# Database
output "rds_endpoint" {
  description = "PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "rds_secret_name" {
  description = "Name of the Secrets Manager secret that stores DB creds"
  value       = aws_secretsmanager_secret.rds.name
}

# DynamoDB
output "dynamodb_transactions_table" {
  description = "Name of the DynamoDB Transactions table"
  value       = aws_dynamodb_table.transactions.name
}

output "dynamodb_jars_table" {
  description = "Name of the DynamoDB Jars table"
  value       = aws_dynamodb_table.jars.name
}

# S3
output "s3_bucket_name" {
  description = "S3 bucket for user-generated assets"
  value       = aws_s3_bucket.assets.bucket
}

# Cognito
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_app_client_id" {
  description = "Cognito User Pool App Client ID"
  value       = aws_cognito_user_pool_client.app_client.id
}