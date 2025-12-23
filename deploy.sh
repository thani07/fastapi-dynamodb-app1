#!/bin/bash

# FastAPI DynamoDB App - AWS Deployment Script
# Replace placeholders with your actual values

AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"
AWS_REGION="us-east-1"
ECR_REPO_NAME="fastapi-dynamodb-app"
ECS_CLUSTER_NAME="fastapi-cluster"
ECS_SERVICE_NAME="fastapi-service"
TASK_FAMILY="fastapi-dynamodb-app"

echo "🚀 Starting AWS Deployment..."

# 1. Create ECR Repository
echo "📦 Creating ECR repository..."
aws ecr create-repository \
    --repository-name $ECR_REPO_NAME \
    --region $AWS_REGION \
    || echo "Repository already exists"

# 2. Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 3. Build Docker image
echo "🔨 Building Docker image..."
docker build -t $ECR_REPO_NAME .

# 4. Tag image
echo "🏷️  Tagging image..."
docker tag ${ECR_REPO_NAME}:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

# 5. Push to ECR
echo "📤 Pushing image to ECR..."
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

# 6. Create CloudWatch log group
echo "📊 Creating CloudWatch log group..."
aws logs create-log-group \
    --log-group-name /ecs/$TASK_FAMILY \
    --region $AWS_REGION \
    || echo "Log group already exists"

# 7. Create ECS Cluster
echo "🏗️  Creating ECS cluster..."
aws ecs create-cluster \
    --cluster-name $ECS_CLUSTER_NAME \
    --region $AWS_REGION \
    || echo "Cluster already exists"

# 8. Register Task Definition
echo "📝 Registering task definition..."
# Make sure ecs-task-definition.json is updated with your AWS_ACCOUNT_ID
aws ecs register-task-definition \
    --cli-input-json file://ecs-task-definition.json

echo "✅ Deployment preparation complete!"
echo ""
echo "Next steps:"
echo "1. Go to AWS Console → ECS → Clusters → $ECS_CLUSTER_NAME"
echo "2. Create a new service using the task definition: $TASK_FAMILY"
echo "3. Configure networking and load balancer"
echo "4. Start the service"
echo ""
echo "Your image URL: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
