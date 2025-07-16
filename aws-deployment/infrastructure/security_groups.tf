###############################################################################
# Security Groups                                                              #
###############################################################################

# Outbound-only SG for Lambda & other egress-only services
resource "aws_security_group" "egress_only" {
  name_prefix = "jargon-ai-egress-${var.environment}-"
  description = "Egress-only access for compute resources"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jargon-ai-egress-${var.environment}"
  }
}

# Inbound rule placeholder for future RDS (PostgreSQL)
resource "aws_security_group" "rds" {
  name_prefix = "jargon-ai-rds-${var.environment}-"
  description = "Allow inbound PostgreSQL from Lambda SGs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from Lambda/compute"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.egress_only.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jargon-ai-rds-${var.environment}"
  }
}