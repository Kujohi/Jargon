variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "production"], var.environment)
    error_message = "Environment must be one of dev, staging, prod, production"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Primary domain for the application (used for OAuth/Cognito callback URLs)"
  type        = string
  default     = "localhost"  # change in production
}

# Optional overrides for RDS sizing – default values are free-tier / dev friendly
variable "rds_instance_class" {
  description = "Instance class for the PostgreSQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial storage size (GB) for PostgreSQL"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage (GB) that RDS Auto-Scaling can grow to"
  type        = number
  default     = 100
}