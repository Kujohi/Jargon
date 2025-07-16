###############################################################################
# Amazon RDS – PostgreSQL                                                     #
###############################################################################

resource "random_password" "db_master" {
  length  = 16
  special = true
}

# Subnet group – use the private subnets created by the VPC module
resource "aws_db_subnet_group" "main" {
  name_prefix = "jargon-ai-${var.environment}-db-"
  subnet_ids  = module.vpc.private_subnets

  tags = {
    Name = "jargon-ai-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "jargon-ai-${var.environment}"

  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = var.environment == "prod" || var.environment == "production" ? "db.t3.medium" : var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name              = "jargondb"
  username             = "jargon_admin"
  password             = random_password.db_master.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.environment == "prod" || var.environment == "production" ? 7 : 0
  skip_final_snapshot     = var.environment != "prod" && var.environment != "production"
  deletion_protection     = var.environment == "prod" || var.environment == "production"

  publicly_accessible = false

  tags = {
    Name = "jargon-ai-postgres-${var.environment}"
  }
}

###############################################################################
# Secrets Manager – store credentials                                         #
###############################################################################

resource "aws_secretsmanager_secret" "rds" {
  name = "jargon-ai/database/${var.environment}"

  tags = {
    Name = "jargon-ai-rds-credentials-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres.username
    password = random_password.db_master.result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = aws_db_instance.postgres.db_name
  })
}