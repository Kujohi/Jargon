# AWS Migration Guide for Jargon AI Prototype

## Overview
This guide will help you migrate your Next.js application from Supabase to a fully AWS-native solution. Your project already has most of the AWS infrastructure code prepared.

## Current Architecture vs Target Architecture

### Current Stack
- **Frontend**: Next.js hosted on Vercel
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **API**: Next.js API routes
- **AI/ML**: Google Gemini + OpenAI
- **Storage**: Supabase Storage

### Target AWS Stack
- **Frontend**: AWS Amplify + CloudFront
- **Database**: Amazon RDS (PostgreSQL)
- **Authentication**: Amazon Cognito
- **API**: AWS Lambda + API Gateway
- **AI/ML**: Amazon Bedrock
- **Storage**: Amazon S3
- **Monitoring**: CloudWatch + X-Ray

## Prerequisites

### 1. AWS Account Setup
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
```

### 2. Required Tools
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python 3.9+
sudo apt-get install python3.9 python3.9-pip
```

### 3. Environment Setup
```bash
# Create S3 bucket for Terraform state (replace with your unique bucket name)
aws s3 mb s3://your-project-terraform-state-bucket

# Clone and prepare project
cd /workspace
npm install
```

## Step-by-Step Migration Process

### Phase 1: Infrastructure Deployment

#### 1. Update Terraform Configuration
```bash
cd aws-deployment/infrastructure

# Edit main.tf to update S3 bucket name for Terraform state
# Replace "Jargon AI-terraform-state" with your unique bucket name
```

#### 2. Deploy Core Infrastructure
```bash
terraform init
terraform plan -var="environment=dev"
terraform apply -auto-approve
```

This will create:
- VPC with public/private subnets
- RDS PostgreSQL database
- Lambda functions
- API Gateway
- Cognito User Pool
- S3 buckets
- CloudFront distribution

### Phase 2: Database Migration

#### 1. Export Data from Supabase
```bash
# Install Supabase CLI
npm install -g supabase

# Export your Supabase data
supabase db dump --db-url="your-supabase-connection-string" > supabase_dump.sql
```

#### 2. Import to RDS
```bash
cd aws-deployment/database

# Get RDS endpoint from Terraform output
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Import data to RDS
psql -h $RDS_ENDPOINT -U jargon_ai_admin -d jargon_ai -f supabase_dump.sql
```

### Phase 3: Backend Migration

#### 1. Deploy Lambda Functions
```bash
cd aws-deployment/backend

# Install dependencies
npm install

# Deploy using Serverless Framework
npx serverless deploy --stage dev
```

#### 2. Update API Endpoints
Your Lambda functions will replace the Next.js API routes. The existing backend services will be migrated to:
- `services/financialService.js` → Lambda function
- `services/accumulativeFinancialService.js` → Lambda function

### Phase 4: Frontend Migration

#### 1. Update Environment Variables
Create `.env.local` with AWS endpoints:
```env
# Replace with your actual AWS resource endpoints
NEXT_PUBLIC_API_URL=https://your-api-gateway-id.execute-api.us-east-1.amazonaws.com/dev
NEXT_PUBLIC_COGNITO_USER_POOL_ID=us-east-1_xxxxxxxxx
NEXT_PUBLIC_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxx
NEXT_PUBLIC_S3_BUCKET=your-s3-bucket-name
NEXT_PUBLIC_CLOUDFRONT_URL=https://your-cloudfront-domain.cloudfront.net
```

#### 2. Update Code for AWS Services
Replace Supabase client with AWS SDK:

```javascript
// Remove Supabase client
// import { supabase } from './services/supabaseClient'

// Add AWS SDK
import { Amplify } from 'aws-amplify';
import { Auth } from 'aws-amplify';
```

#### 3. Deploy to AWS Amplify
```bash
cd aws-deployment/frontend

# Initialize Amplify
amplify init

# Push to AWS
amplify push
```

### Phase 5: ML Service Migration

#### 1. Deploy ML Service to ECS
```bash
cd aws-deployment/ml-service

# Build Docker image
docker build -t jargon-ai-ml .

# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
docker tag jargon-ai-ml:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/jargon-ai-ml:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/jargon-ai-ml:latest
```

## Quick Start with Automated Script

You can use the prepared deployment script for automated deployment:

```bash
cd aws-deployment

# Make script executable
chmod +x deploy.sh

# Run deployment (dev environment)
./deploy.sh dev us-east-1 your-domain.com
```

## Cost Estimation

### Development Environment: ~$140/month
- RDS PostgreSQL (db.t3.micro): $15
- Lambda: $0.20
- API Gateway: $3.50
- DynamoDB: $25
- S3: $0.15
- CloudFront: $85
- Other services: ~$11

### Production Environment: ~$1,200/month
- RDS PostgreSQL (db.t3.medium): $70
- Lambda: $2
- API Gateway: $35
- DynamoDB: $100
- CloudFront: $850
- Other services: ~$143

## Migration Checklist

### Pre-Migration
- [ ] AWS account setup and credentials configured
- [ ] All prerequisite tools installed
- [ ] Domain name registered (if using custom domain)
- [ ] SSL certificate requested in ACM
- [ ] Terraform state bucket created

### Infrastructure
- [ ] VPC and networking deployed
- [ ] RDS PostgreSQL instance created
- [ ] Lambda functions deployed
- [ ] API Gateway configured
- [ ] Cognito User Pool created
- [ ] S3 buckets created
- [ ] CloudFront distribution configured

### Data Migration
- [ ] Supabase data exported
- [ ] Database schema migrated to RDS
- [ ] User data migrated to Cognito
- [ ] File uploads migrated to S3

### Application
- [ ] Frontend updated for AWS services
- [ ] API endpoints updated
- [ ] Authentication flow updated
- [ ] Environment variables configured
- [ ] SSL/TLS configured

### Testing
- [ ] API endpoints tested
- [ ] Database connections verified
- [ ] Authentication flow tested
- [ ] File uploads tested
- [ ] Performance testing completed

### Go-Live
- [ ] DNS records updated
- [ ] SSL certificate validated
- [ ] Monitoring configured
- [ ] Backup strategy implemented
- [ ] Rollback plan prepared

## Security Considerations

1. **VPC Setup**: All resources are in private subnets with NAT Gateway
2. **Database Security**: RDS is only accessible from Lambda functions
3. **API Security**: API Gateway with throttling and API keys
4. **Storage Security**: S3 bucket policies and encryption
5. **Monitoring**: CloudWatch logs and X-Ray tracing

## Post-Migration Tasks

1. **Monitor Performance**: Use CloudWatch dashboards
2. **Set Up Alerts**: Configure CloudWatch alarms
3. **Cost Optimization**: Monitor AWS Cost Explorer
4. **Security Audits**: Regular security reviews
5. **Backup Strategy**: Automated RDS backups

## Support and Troubleshooting

### Common Issues
1. **RDS Connection**: Check security groups and VPC configuration
2. **Lambda Timeouts**: Adjust memory and timeout settings
3. **API Gateway CORS**: Configure proper CORS headers
4. **Cognito Auth**: Check user pool and client configuration

### Monitoring
- **CloudWatch Logs**: Monitor Lambda function logs
- **X-Ray**: Trace API requests
- **RDS Performance Insights**: Monitor database performance

## Next Steps

1. Start with the development environment deployment
2. Test all functionality thoroughly
3. Deploy to staging environment
4. Perform production deployment
5. Monitor and optimize performance

Your project is well-prepared for AWS migration with existing infrastructure code, scripts, and documentation. The migration should be straightforward following this guide.