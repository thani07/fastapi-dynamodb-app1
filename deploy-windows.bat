@echo off
REM FastAPI DynamoDB App - AWS Deployment for Windows
REM Run this in Command Prompt or PowerShell

echo ==========================================
echo FastAPI DynamoDB App - AWS Deployment
echo ==========================================
echo.

REM Configuration - REPLACE THESE
set AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID
set AWS_REGION=us-east-1
set ECR_REPO=fastapi-dynamodb-app

echo Step 1: Get AWS Account ID
echo Run this command and save the number:
echo   aws sts get-caller-identity --query Account --output text
echo.
pause

echo Step 2: Creating ECR repository...
aws ecr create-repository --repository-name %ECR_REPO% --region %AWS_REGION%
echo.

echo Step 3: Logging into ECR...
FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO SET ECR_PASSWORD=%%i
echo %ECR_PASSWORD% | docker login --username AWS --password-stdin %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
echo.

echo Step 4: Building Docker image...
docker build -t %ECR_REPO%:latest .
echo.

echo Step 5: Tagging image...
docker tag %ECR_REPO%:latest %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPO%:latest
echo.

echo Step 6: Pushing image to ECR...
docker push %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPO%:latest
echo.

echo Step 7: Creating CloudWatch log group...
aws logs create-log-group --log-group-name /ecs/fastapi-dynamodb-app --region %AWS_REGION%
echo.

echo Step 8: Creating ECS cluster...
aws ecs create-cluster --cluster-name fastapi-cluster --region %AWS_REGION%
echo.

echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.
echo Your ECR Image:
echo %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPO%:latest
echo.
echo Next: Follow DEPLOYMENT-GUIDE.md Part 3 (AWS Console Setup)
echo.
pause
