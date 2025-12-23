# 🚀 Quick Deployment Reference

## Prerequisites Checklist
- [ ] AWS Account created
- [ ] AWS CLI installed
- [ ] Docker Desktop running
- [ ] DynamoDB table "Users" exists

## Get Your AWS Account ID
```bash
aws sts get-caller-identity --query Account --output text
```

## Quick Deploy Commands (Replace YOUR_ACCOUNT_ID)

```bash
# 1. Set variables
export AWS_ACCOUNT_ID="123456789012"  # YOUR ACCOUNT ID HERE
export AWS_REGION="us-east-1"

# 2. Create & login to ECR
aws ecr create-repository --repository-name fastapi-dynamodb-app --region $AWS_REGION
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 3. Build & push Docker image
docker build -t fastapi-dynamodb-app:latest .
docker tag fastapi-dynamodb-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fastapi-dynamodb-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fastapi-dynamodb-app:latest

# 4. Create ECS resources
aws logs create-log-group --log-group-name /ecs/fastapi-dynamodb-app --region $AWS_REGION
aws ecs create-cluster --cluster-name fastapi-cluster --region $AWS_REGION

# 5. Update task definition JSON with your account ID, then:
aws ecs register-task-definition --cli-input-json file://ecs-task-definition-ec2.json
```

## AWS Console Steps (Manual)

1. **ECS Console** → **fastapi-cluster** → Add EC2 instance (t2.micro)
2. **Create Service**:
   - Launch type: EC2
   - Task: fastapi-dynamodb-app
   - Tasks: 1
3. **Get Public IP** from EC2 console
4. **Access API**: http://YOUR_EC2_PUBLIC_IP/docs

## Test Your API

```bash
# Replace with your EC2 public IP
API="http://YOUR_EC2_IP"

# Create user
curl -X POST "$API/users/" -H "Content-Type: application/json" \
  -d '{"user_id":"user_001","name":"Test User","email":"test@example.com"}'

# Get user
curl "$API/users/user_001"

# List users
curl "$API/users/"
```

## Update Application

```bash
# Rebuild and push
docker build -t fastapi-dynamodb-app:latest .
docker tag fastapi-dynamodb-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fastapi-dynamodb-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fastapi-dynamodb-app:latest

# Force new deployment
aws ecs update-service --cluster fastapi-cluster --service fastapi-service --force-new-deployment
```

## Monitor

- **Logs**: CloudWatch → Log groups → `/ecs/fastapi-dynamodb-app`
- **Metrics**: ECS Console → Cluster → Service → Metrics
- **Cost**: Billing Console → Free Tier

## Important URLs

- ECS Console: https://console.aws.amazon.com/ecs
- ECR Console: https://console.aws.amazon.com/ecr
- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
- Free Tier Usage: https://console.aws.amazon.com/billing/home#/freetier

## Free Tier Limits (12 months)

- ✅ 750 hours/month t2.micro EC2 (= 1 instance 24/7)
- ✅ 25 GB DynamoDB storage
- ✅ 500 MB ECR storage
- ✅ 5 GB CloudWatch logs

Keep within these limits = $0/month! 🎉
