#!/bin/bash

# Quick Start AWS Migration Script for Jargon AI Prototype
# This script helps you get started with AWS migration quickly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Jargon AI AWS Migration Quick Start${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install AWS CLI
install_aws_cli() {
    echo -e "${YELLOW}📦 Installing AWS CLI...${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    echo -e "${GREEN}✅ AWS CLI installed successfully${NC}"
}

# Function to install Terraform
install_terraform() {
    echo -e "${YELLOW}📦 Installing Terraform...${NC}"
    wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
    unzip terraform_1.6.6_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.6.6_linux_amd64.zip
    echo -e "${GREEN}✅ Terraform installed successfully${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command_exists aws; then
        echo -e "${RED}❌ AWS CLI not found${NC}"
        read -p "Would you like to install AWS CLI? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_aws_cli
        else
            echo -e "${RED}AWS CLI is required. Please install it manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ AWS CLI found${NC}"
    fi
    
    # Check Terraform
    if ! command_exists terraform; then
        echo -e "${RED}❌ Terraform not found${NC}"
        read -p "Would you like to install Terraform? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_terraform
        else
            echo -e "${RED}Terraform is required. Please install it manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Terraform found${NC}"
    fi
    
    # Check Node.js
    if ! command_exists node; then
        echo -e "${RED}❌ Node.js not found${NC}"
        echo -e "${YELLOW}Please install Node.js 18+ manually:${NC}"
        echo "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
        echo "sudo apt-get install -y nodejs"
        exit 1
    else
        echo -e "${GREEN}✅ Node.js found ($(node --version))${NC}"
    fi
    
    # Check Python
    if ! command_exists python3; then
        echo -e "${RED}❌ Python 3 not found${NC}"
        echo -e "${YELLOW}Please install Python 3.9+ manually:${NC}"
        echo "sudo apt-get install python3.9 python3.9-pip"
        exit 1
    else
        echo -e "${GREEN}✅ Python 3 found ($(python3 --version))${NC}"
    fi
}

# Function to configure AWS credentials
configure_aws() {
    echo -e "${YELLOW}🔧 Configuring AWS credentials...${NC}"
    
    # Check if AWS credentials are already configured
    if aws sts get-caller-identity &>/dev/null; then
        echo -e "${GREEN}✅ AWS credentials already configured${NC}"
        aws sts get-caller-identity
        read -p "Would you like to reconfigure AWS credentials? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            aws configure
        fi
    else
        echo -e "${YELLOW}Please configure your AWS credentials:${NC}"
        aws configure
    fi
}

# Function to create Terraform state bucket
create_terraform_state_bucket() {
    echo -e "${YELLOW}🪣 Setting up Terraform state bucket...${NC}"
    
    # Get AWS account ID
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    BUCKET_NAME="jargon-ai-terraform-state-${AWS_ACCOUNT_ID}"
    
    # Check if bucket already exists
    if aws s3 ls "s3://${BUCKET_NAME}" &>/dev/null; then
        echo -e "${GREEN}✅ Terraform state bucket already exists: ${BUCKET_NAME}${NC}"
    else
        echo -e "${YELLOW}Creating Terraform state bucket: ${BUCKET_NAME}${NC}"
        aws s3 mb "s3://${BUCKET_NAME}"
        
        # Enable versioning
        aws s3api put-bucket-versioning \
            --bucket "${BUCKET_NAME}" \
            --versioning-configuration Status=Enabled
        
        # Enable server-side encryption
        aws s3api put-bucket-encryption \
            --bucket "${BUCKET_NAME}" \
            --server-side-encryption-configuration '{
                "Rules": [
                    {
                        "ApplyServerSideEncryptionByDefault": {
                            "SSEAlgorithm": "AES256"
                        }
                    }
                ]
            }'
        
        echo -e "${GREEN}✅ Terraform state bucket created: ${BUCKET_NAME}${NC}"
    fi
    
    # Update Terraform backend configuration
    echo -e "${YELLOW}📝 Updating Terraform backend configuration...${NC}"
    sed -i "s/Jargon AI-terraform-state/${BUCKET_NAME}/g" aws-deployment/infrastructure/main.tf
    echo -e "${GREEN}✅ Terraform backend configuration updated${NC}"
}

# Function to install project dependencies
install_dependencies() {
    echo -e "${YELLOW}📦 Installing project dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Project dependencies installed${NC}"
}

# Function to validate setup
validate_setup() {
    echo -e "${YELLOW}🔍 Validating setup...${NC}"
    
    # Check Terraform configuration
    cd aws-deployment/infrastructure
    terraform init
    terraform validate
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Terraform configuration is valid${NC}"
    else
        echo -e "${RED}❌ Terraform configuration has errors${NC}"
        exit 1
    fi
    
    cd ../..
}

# Function to display next steps
display_next_steps() {
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "${YELLOW}1. Review the AWS_MIGRATION_GUIDE.md file${NC}"
    echo -e "${YELLOW}2. Update environment variables in .env.local${NC}"
    echo -e "${YELLOW}3. Deploy infrastructure:${NC}"
    echo "   cd aws-deployment/infrastructure"
    echo "   terraform plan -var=\"environment=dev\""
    echo "   terraform apply"
    echo ""
    echo -e "${YELLOW}4. Or use the automated deployment script:${NC}"
    echo "   cd aws-deployment"
    echo "   chmod +x deploy.sh"
    echo "   ./deploy.sh dev us-east-1 your-domain.com"
    echo ""
    echo -e "${BLUE}Cost Estimation:${NC}"
    echo -e "${YELLOW}Development: ~$140/month${NC}"
    echo -e "${YELLOW}Production: ~$1,200/month${NC}"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo -e "${YELLOW}• AWS_MIGRATION_GUIDE.md - Complete migration guide${NC}"
    echo -e "${YELLOW}• aws-deployment/README.md - Deployment instructions${NC}"
    echo -e "${YELLOW}• aws-deployment/COST_ESTIMATION.md - Detailed cost breakdown${NC}"
    echo -e "${YELLOW}• aws-deployment/MIGRATION_CHECKLIST.md - Migration checklist${NC}"
}

# Main execution
main() {
    check_prerequisites
    configure_aws
    create_terraform_state_bucket
    install_dependencies
    validate_setup
    display_next_steps
}

# Run main function
main