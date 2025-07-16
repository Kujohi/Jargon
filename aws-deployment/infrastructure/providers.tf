terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state stored in an S3 bucket so that multiple team members & CI can share state safely
  backend "s3" {
    bucket = "jargon-ai-terraform-state" # CREATE THIS BUCKET ONCE PER ACCOUNT/REGION
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  # Tagging best-practice: propagate common tags to all resources automatically
  default_tags {
    tags = {
      Project     = "JargonAI-Prototype"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}