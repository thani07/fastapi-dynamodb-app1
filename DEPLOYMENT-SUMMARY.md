# 🎯 AWS Deployment - Complete Summary

## What You're Deploying
FastAPI application with DynamoDB CRUD operations running on AWS ECS with EC2 (Free Tier).

## Total Cost: **FREE** for 12 months (if within limits)

---

## 📁 Files Created for Deployment

1. **deploy-windows.ps1** - PowerShell deployment script (Windows)
2. **deploy-windows.bat** - Batch deployment script (Windows CMD)
3. **deploy-ecs-ec2.sh** - Bash deployment script (Linux/Mac)
4. **ecs-task-definition-ec2.json** - ECS task configuration
5. **DEPLOYMENT-GUIDE.md** - Complete step-by-step guide
6. **QUICK-REFERENCE.md** - Quick command reference
7. **.env.example** - Environment variables template

---

## 🚀 Quick Start (Choose Your OS)

### Windows PowerShell:
```powershell
# 1. Get your AWS Account ID
aws sts get-caller-identity --query Account --output text

# 2. Edit deploy-windows.ps1 - Replace YOUR_AWS_ACCOUNT_ID

# 3. Run deployment
.\deploy-windows.ps1
```

### Windows Command Prompt:
```cmd
REM 1. Get your AWS Account ID
aws sts get-caller-identity --query Account --output text

REM 2. Edit deploy-windows.bat - Replace YOUR_AWS_ACCOUNT_ID

REM 3. Run deployment
deploy-windows.bat
```

### Linux/Mac:
```bash
# 1. Get your AWS Account ID
aws sts get-caller-identity --query Account --output text

# 2. Edit deploy-ecs-ec2.sh - Replace YOUR_AWS_ACCOUNT_ID

# 3. Run deployment
chmod +x deploy-ecs-ec2.sh
./deploy-ecs-ec2.sh
```

---

## 📋 Deployment Steps Overview

### Phase 1: Automated (Script)
✅ Create ECR repository  
✅ Build Docker image  
✅ Push image to ECR  
✅ Create CloudWatch log group  
✅ Create ECS cluster  

### Phase 2: Manual (AWS Console) - 5 minutes
1. Update `ecs-task-definition-ec2.json` with your AWS Account ID
2. Register task definition
3. Add t2.micro EC2 instance to cluster
4. Create ECS service
5. Get EC2 public IP

### Phase 3: Test
Access your API at: `http://YOUR_EC2_PUBLIC_IP/docs`

---

## 🎓 Before You Start

### 1. Prerequisites
- [ ] AWS Account (https://aws.amazon.com/free/)
- [ ] AWS CLI installed (https://aws.amazon.com/cli/)
- [ ] Docker Desktop running
- [ ] Your code tested locally

### 2. Configure AWS CLI
```bash
aws configure
```
You'll need:
- AWS Access Key ID (from IAM user)
- AWS Secret Access Key
- Region: us-east-1
- Output: json

### 3. Verify DynamoDB Table
```bash
aws dynamodb describe-table --table-name Users --region us-east-1
```
If not exists, create it:
```bash
aws dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

---

## 💡 Important Notes

### Free Tier (12 months)
- **EC2**: 750 hours/month of t2.micro = 1 instance 24/7 FREE
- **ECS**: No charge for ECS itself
- **ECR**: 500 MB storage FREE
- **DynamoDB**: 25 GB + 200M requests/month FREE
- **CloudWatch**: 5 GB logs FREE

### After Free Tier
- t2.micro EC2: ~$8/month
- DynamoDB on-demand: ~$1-5/month (depends on usage)
- Total: ~$10-15/month

### Security Best Practice
The task definition includes your AWS credentials. For production:
1. Use IAM roles instead of hardcoded credentials
2. Use AWS Secrets Manager for sensitive data
3. Don't commit credentials to Git

---

## 🔍 Monitoring Your Deployment

### Check ECS Service Status
```bash
aws ecs describe-services \
    --cluster fastapi-cluster \
    --services fastapi-service \
    --region us-east-1
```

### View Application Logs
```bash
aws logs tail /ecs/fastapi-dynamodb-app --follow --region us-east-1
```

### Check Free Tier Usage
https://console.aws.amazon.com/billing/home#/freetier

---

## 🧪 Testing Your Deployed API

```bash
# Replace with your EC2 public IP
API_URL="http://YOUR_EC2_PUBLIC_IP"

# Health check
curl $API_URL/

# API Documentation
# Open in browser: http://YOUR_EC2_PUBLIC_IP/docs

# Create user
curl -X POST "$API_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_001",
    "name": "John Doe",
    "email": "john@example.com"
  }'

# Get user
curl "$API_URL/users/user_001"

# List all users
curl "$API_URL/users/"

# Update user
curl -X PUT "$API_URL/users/user_001" \
  -H "Content-Type: application/json" \
  -d '{"name": "John Updated", "email": "john.new@example.com"}'

# Delete user
curl -X DELETE "$API_URL/users/user_001"
```

---

## 🔄 Updating Your Application

When you make code changes:

```bash
# 1. Rebuild and push (automated)
AWS_ACCOUNT_ID="your_account_id"
docker build -t fastapi-dynamodb-app:latest .
docker tag fastapi-dynamodb-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest

# 2. Force new deployment
aws ecs update-service \
    --cluster fastapi-cluster \
    --service fastapi-service \
    --force-new-deployment \
    --region us-east-1
```

---

## 🛑 Stopping/Cleanup (When Done)

### Temporary Stop (Keep resources, stop charges)
```bash
# Stop service (scales to 0 tasks)
aws ecs update-service \
    --cluster fastapi-cluster \
    --service fastapi-service \
    --desired-count 0 \
    --region us-east-1

# Stop EC2 instance (via console)
```

### Complete Cleanup (Delete everything)
```bash
# Delete service
aws ecs delete-service \
    --cluster fastapi-cluster \
    --service fastapi-service \
    --force \
    --region us-east-1

# Wait 1-2 minutes, then delete cluster
aws ecs delete-cluster \
    --cluster fastapi-cluster \
    --region us-east-1

# Delete ECR repository
aws ecr delete-repository \
    --repository-name fastapi-dynamodb-app \
    --force \
    --region us-east-1

# Terminate EC2 instances (via console)
# Delete DynamoDB table (if not needed)
aws dynamodb delete-table --table-name Users --region us-east-1
```

---

## 🆘 Troubleshooting

### Issue: Container won't start
**Solution**: Check CloudWatch logs
```bash
aws logs tail /ecs/fastapi-dynamodb-app --follow
```

### Issue: Can't access API
**Check**:
1. EC2 instance is running
2. Security group allows port 80 inbound
3. ECS task status is RUNNING
4. Using public IP (not private)

### Issue: DynamoDB access denied
**Solution**:
1. Verify IAM task role has DynamoDB permissions
2. Check credentials in task definition
3. Ensure table name matches ("Users")

### Issue: "No space left on device"
**Solution**: EC2 instance disk full - use larger instance or clean up

---

## 📞 Support Resources

- **AWS Free Tier FAQ**: https://aws.amazon.com/free/free-tier-faqs/
- **ECS Documentation**: https://docs.aws.amazon.com/ecs/
- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **DynamoDB Documentation**: https://docs.aws.amazon.com/dynamodb/

---

## ✅ Success Checklist

- [ ] Ran deployment script successfully
- [ ] Updated task definition with Account ID
- [ ] Registered task definition
- [ ] Added t2.micro EC2 instance to cluster
- [ ] Created ECS service with 1 task
- [ ] Task status shows RUNNING
- [ ] Can access health check endpoint
- [ ] API docs accessible at /docs
- [ ] Successfully created a test user
- [ ] Successfully retrieved the user
- [ ] Checked CloudWatch logs working
- [ ] Verified Free Tier usage

**Congratulations! Your FastAPI app is now live on AWS! 🎉**

---

For detailed instructions, see **DEPLOYMENT-GUIDE.md**
For quick commands, see **QUICK-REFERENCE.md**
