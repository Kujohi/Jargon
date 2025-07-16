###############################################################################
# Systems Manager Parameter Store – expose outputs                              #
###############################################################################

locals {
  ssm_prefix = "/jargon-ai/${var.environment}"
}

resource "aws_ssm_parameter" "lambda_sg" {
  name  = "${local.ssm_prefix}/lambda-security-group-id"
  type  = "String"
  value = aws_security_group.egress_only.id
}

resource "aws_ssm_parameter" "private_subnet_1" {
  name  = "${local.ssm_prefix}/private-subnet-1"
  type  = "String"
  value = module.vpc.private_subnets[0]
}

resource "aws_ssm_parameter" "private_subnet_2" {
  name  = "${local.ssm_prefix}/private-subnet-2"
  type  = "String"
  value = module.vpc.private_subnets[1]
}

resource "aws_ssm_parameter" "lambda_role" {
  name  = "${local.ssm_prefix}/lambda-execution-role-arn"
  type  = "String"
  value = aws_iam_role.lambda_execution.arn
}

resource "aws_ssm_parameter" "rds_secret" {
  name  = "${local.ssm_prefix}/rds-secret-name"
  type  = "String"
  value = aws_secretsmanager_secret.rds.name
}

resource "aws_ssm_parameter" "dynamodb_transactions" {
  name  = "${local.ssm_prefix}/dynamodb-transactions-table"
  type  = "String"
  value = aws_dynamodb_table.transactions.name
}

resource "aws_ssm_parameter" "dynamodb_jars" {
  name  = "${local.ssm_prefix}/dynamodb-jars-table"
  type  = "String"
  value = aws_dynamodb_table.jars.name
}

resource "aws_ssm_parameter" "s3_bucket" {
  name  = "${local.ssm_prefix}/s3-bucket-name"
  type  = "String"
  value = aws_s3_bucket.assets.bucket
}

resource "aws_ssm_parameter" "cognito_pool" {
  name  = "${local.ssm_prefix}/cognito-user-pool-id"
  type  = "String"
  value = aws_cognito_user_pool.main.id
}

resource "aws_ssm_parameter" "cognito_client" {
  name  = "${local.ssm_prefix}/cognito-app-client-id"
  type  = "String"
  value = aws_cognito_user_pool_client.app_client.id
}