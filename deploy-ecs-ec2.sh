#!/bin/bash

# AWS Deployment Script for FastAPI DynamoDB App
# Using ECS on EC2 (Free Tier eligible)

set -e

# Configuration - REPLACE THESE VALUES
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"  # Get from: aws sts get-caller-identity --query Account --output text
AWS_REGION="us-east-1"
ECR_REPO_NAME="fastapi-dynamodb-app"
ECS_CLUSTER_NAME="fastapi-cluster"
KEY_PAIR_NAME="fastapi-keypair"  # Your EC2 key pair name

echo "=========================================="
echo "🚀 FastAPI DynamoDB App AWS Deployment"
echo "=========================================="
echo ""

# Step 1: Create ECR Repository
echo "📦 Step 1: Creating ECR repository..."
aws ecr create-repository \
    --repository-name $ECR_REPO_NAME \
    --region $AWS_REGION 2>/dev/null \
    || echo "   ℹ️  Repository already exists"
echo "   ✅ ECR repository ready"
echo ""

# Step 2: Build and Push Docker Image
echo "🔨 Step 2: Building Docker image..."
docker build -t $ECR_REPO_NAME:latest .
echo "   ✅ Docker image built"
echo ""

echo "🔐 Step 3: Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
echo "   ✅ Logged into ECR"
echo ""

echo "🏷️  Step 4: Tagging image..."
docker tag ${ECR_REPO_NAME}:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
echo "   ✅ Image tagged"
echo ""

echo "📤 Step 5: Pushing image to ECR..."
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
echo "   ✅ Image pushed to ECR"
echo ""

# Step 3: Create CloudWatch Log Group
echo "📊 Step 6: Creating CloudWatch log group..."
aws logs create-log-group \
    --log-group-name /ecs/fastapi-dynamodb-app \
    --region $AWS_REGION 2>/dev/null \
    || echo "   ℹ️  Log group already exists"
echo "   ✅ CloudWatch log group ready"
echo ""

# Step 4: Create ECS Cluster
echo "🏗️  Step 7: Creating ECS cluster..."
aws ecs create-cluster \
    --cluster-name $ECS_CLUSTER_NAME \
    --region $AWS_REGION 2>/dev/null \
    || echo "   ℹ️  Cluster already exists"
echo "   ✅ ECS cluster ready"
echo ""

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Next Steps (Manual - Do in AWS Console):"
echo ""
echo "1. Go to ECS Console: https://console.aws.amazon.com/ecs"
echo "2. Click on cluster: $ECS_CLUSTER_NAME"
echo "3. Click 'Add Instance' or 'Create EC2 instance'"
echo "   - Instance type: t2.micro (FREE TIER)"
echo "   - Key pair: $KEY_PAIR_NAME"
echo "   - Follow the wizard"
echo ""
echo "4. Create Task Definition (use ecs-task-definition-ec2.json)"
echo "5. Create Service and deploy"
echo ""
echo "🔗 Your ECR Image URI:"
echo "   ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
echo ""
