# FastAPI DynamoDB App - AWS Deployment for Windows PowerShell

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "FastAPI DynamoDB App - AWS Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration - REPLACE THESE
$AWS_ACCOUNT_ID = "YOUR_AWS_ACCOUNT_ID"  # Get from: aws sts get-caller-identity
$AWS_REGION = "us-east-1"
$ECR_REPO = "fastapi-dynamodb-app"
$ECS_CLUSTER = "fastapi-cluster"

Write-Host "Step 1: Get your AWS Account ID" -ForegroundColor Yellow
Write-Host "Run this command and update the script:" -ForegroundColor Yellow
Write-Host "  aws sts get-caller-identity --query Account --output text" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter when you've updated AWS_ACCOUNT_ID in this script"

Write-Host ""
Write-Host "Step 2: Creating ECR repository..." -ForegroundColor Yellow
aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION 2>$null
if ($?) { Write-Host "✓ ECR repository created" -ForegroundColor Green }
else { Write-Host "ℹ Repository already exists" -ForegroundColor Gray }

Write-Host ""
Write-Host "Step 3: Logging into ECR..." -ForegroundColor Yellow
$ECR_PASSWORD = aws ecr get-login-password --region $AWS_REGION
$ECR_PASSWORD | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
if ($?) { Write-Host "✓ Logged into ECR" -ForegroundColor Green }

Write-Host ""
Write-Host "Step 4: Building Docker image..." -ForegroundColor Yellow
docker build -t "${ECR_REPO}:latest" .
if ($?) { Write-Host "✓ Docker image built" -ForegroundColor Green }

Write-Host ""
Write-Host "Step 5: Tagging image..." -ForegroundColor Yellow
docker tag "${ECR_REPO}:latest" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPO}:latest"
if ($?) { Write-Host "✓ Image tagged" -ForegroundColor Green }

Write-Host ""
Write-Host "Step 6: Pushing image to ECR..." -ForegroundColor Yellow
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPO}:latest"
if ($?) { Write-Host "✓ Image pushed to ECR" -ForegroundColor Green }

Write-Host ""
Write-Host "Step 7: Creating CloudWatch log group..." -ForegroundColor Yellow
aws logs create-log-group --log-group-name /ecs/fastapi-dynamodb-app --region $AWS_REGION 2>$null
if ($?) { Write-Host "✓ Log group created" -ForegroundColor Green }
else { Write-Host "ℹ Log group already exists" -ForegroundColor Gray }

Write-Host ""
Write-Host "Step 8: Creating ECS cluster..." -ForegroundColor Yellow
aws ecs create-cluster --cluster-name $ECS_CLUSTER --region $AWS_REGION 2>$null
if ($?) { Write-Host "✓ ECS cluster created" -ForegroundColor Green }
else { Write-Host "ℹ Cluster already exists" -ForegroundColor Gray }

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Deployment Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Your ECR Image URI:" -ForegroundColor Yellow
Write-Host "  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPO}:latest" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update ecs-task-definition-ec2.json with your AWS Account ID" -ForegroundColor White
Write-Host "2. Register task definition:" -ForegroundColor White
Write-Host "   aws ecs register-task-definition --cli-input-json file://ecs-task-definition-ec2.json" -ForegroundColor Green
Write-Host "3. Follow DEPLOYMENT-GUIDE.md Part 3 for AWS Console setup" -ForegroundColor White
Write-Host "4. Add t2.micro EC2 instance to cluster" -ForegroundColor White
Write-Host "5. Create and start ECS service" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Useful Links:" -ForegroundColor Yellow
Write-Host "  ECS Console: https://console.aws.amazon.com/ecs" -ForegroundColor Cyan
Write-Host "  Free Tier: https://console.aws.amazon.com/billing/home#/freetier" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
