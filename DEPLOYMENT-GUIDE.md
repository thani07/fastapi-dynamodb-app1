# Complete AWS Deployment Guide - ECS on EC2 (Free Tier)

## Prerequisites
1. AWS Account (Free Tier eligible)
2. AWS CLI installed: https://aws.amazon.com/cli/
3. Docker Desktop running
4. DynamoDB table "Users" created with partition key "user_id"

## Step-by-Step Deployment

### PART 1: AWS Setup (One-time)

#### 1. Configure AWS CLI
```bash
aws configure
```
Enter:
- AWS Access Key ID: [Your IAM user access key]
- AWS Secret Access Key: [Your IAM user secret key]
- Default region: us-east-1
- Default output format: json

#### 2. Get Your AWS Account ID
```bash
aws sts get-caller-identity --query Account --output text
```
Save this number - you'll need it!

#### 3. Create EC2 Key Pair (for SSH access)
```bash
aws ec2 create-key-pair --key-name fastapi-keypair --query 'KeyMaterial' --output text > fastapi-keypair.pem
chmod 400 fastapi-keypair.pem  # Linux/Mac
```
On Windows PowerShell:
```powershell
aws ec2 create-key-pair --key-name fastapi-keypair --query 'KeyMaterial' --output text | Out-File -Encoding ASCII fastapi-keypair.pem
```

#### 4. Create IAM Roles

**A. Task Execution Role** (for ECS to pull images):
```bash
# Create trust policy file
cat > ecs-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document file://ecs-trust-policy.json

# Attach managed policy
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

**B. Task Role** (for app to access DynamoDB):
```bash
# Create DynamoDB policy
cat > dynamodb-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
    --role-name ecsTaskRole \
    --assume-role-policy-document file://ecs-trust-policy.json

# Attach the policy
aws iam put-role-policy \
    --role-name ecsTaskRole \
    --policy-name DynamoDBAccess \
    --policy-document file://dynamodb-policy.json
```

#### 5. Create DynamoDB Table (if not exists)
```bash
aws dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

---

### PART 2: Deploy Application

#### 1. Update Configuration Files

**Edit `ecs-task-definition-ec2.json`:**
- Replace `<YOUR_AWS_ACCOUNT_ID>` with your actual AWS account ID (3 places)

**Edit `deploy-ecs-ec2.sh`:**
- Replace `YOUR_AWS_ACCOUNT_ID` with your actual AWS account ID
- Replace `fastapi-keypair` if you used a different key pair name

#### 2. Run Deployment Script

On Linux/Mac:
```bash
chmod +x deploy-ecs-ec2.sh
./deploy-ecs-ec2.sh
```

On Windows (Git Bash):
```bash
bash deploy-ecs-ec2.sh
```

Or manually run these commands:
```bash
# Set your AWS Account ID
AWS_ACCOUNT_ID="123456789012"  # Replace with yours
AWS_REGION="us-east-1"

# Create ECR repository
aws ecr create-repository --repository-name fastapi-dynamodb-app --region us-east-1

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com

# Build and push image
docker build -t fastapi-dynamodb-app:latest .
docker tag fastapi-dynamodb-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest

# Create log group
aws logs create-log-group --log-group-name /ecs/fastapi-dynamodb-app --region us-east-1

# Create ECS cluster
aws ecs create-cluster --cluster-name fastapi-cluster --region us-east-1
```

---

### PART 3: AWS Console Setup (Final Steps)

#### 1. Add EC2 Instance to ECS Cluster

Go to: https://console.aws.amazon.com/ecs

1. Click on **Clusters** → **fastapi-cluster**
2. Click **Infrastructure** tab → **Create**
3. Choose **Amazon EC2 instances**
4. Configure:
   - **Operating system**: Amazon Linux 2
   - **EC2 instance type**: **t2.micro** (FREE TIER)
   - **Desired capacity**: 1
   - **SSH key pair**: fastapi-keypair
   - **Networking**: Default VPC, public subnet
   - **Security group**: Create new
     - Allow inbound: Port 80 (HTTP) from 0.0.0.0/0
     - Allow inbound: Port 22 (SSH) from your IP
5. Click **Create**

Wait 2-3 minutes for the instance to register with the cluster.

#### 2. Register Task Definition

```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition-ec2.json
```

#### 3. Create ECS Service

In AWS Console:
1. Go to **Clusters** → **fastapi-cluster**
2. Click **Services** tab → **Create**
3. Configure:
   - **Launch type**: EC2
   - **Task definition**: fastapi-dynamodb-app (latest)
   - **Service name**: fastapi-service
   - **Number of tasks**: 1
   - **Deployment type**: Rolling update
4. Click **Create**

Wait for the service to start (check **Tasks** tab - should show RUNNING)

#### 4. Get Your Application URL

1. Go to **EC2** Console
2. Find your instance (tag: ECS Instance - fastapi-cluster)
3. Copy **Public IPv4 address**
4. Access your API: `http://YOUR_EC2_PUBLIC_IP/`
5. API Docs: `http://YOUR_EC2_PUBLIC_IP/docs`

---

## Testing Your API

```bash
# Replace with your EC2 public IP
API_URL="http://YOUR_EC2_PUBLIC_IP"

# Health check
curl $API_URL/

# Create user
curl -X POST "$API_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_001", "name": "John Doe", "email": "john@example.com"}'

# Get user
curl "$API_URL/users/user_001"

# List all users
curl "$API_URL/users/"

# Update user
curl -X PUT "$API_URL/users/user_001" \
  -H "Content-Type: application/json" \
  -d '{"name": "John Updated"}'

# Delete user
curl -X DELETE "$API_URL/users/user_001"
```

---

## Monitoring

### CloudWatch Logs
1. Go to CloudWatch Console
2. Click **Log groups**
3. Select `/ecs/fastapi-dynamodb-app`
4. View your application logs

### ECS Metrics
1. Go to ECS Console
2. Click your cluster → Service
3. View **Metrics** tab for CPU/Memory usage

---

## Cost Estimation (Free Tier)

### Included in Free Tier (12 months):
- ✅ t2.micro EC2 instance: 750 hours/month (1 instance 24/7)
- ✅ ECS: No additional charge
- ✅ ECR: 500 MB storage
- ✅ DynamoDB: 25 GB storage + 25 WCU + 25 RCU
- ✅ CloudWatch: 10 custom metrics, 5 GB logs

### After Free Tier or if exceeded:
- EC2 t2.micro: ~$8/month
- DynamoDB on-demand: Pay per request (~$0.25 per million reads)
- Data transfer: First 100 GB free/month

**Total: FREE for 12 months if within limits, ~$10-15/month after**

---

## Updating Your Application

When you make code changes:

```bash
# 1. Rebuild and push image
docker build -t fastapi-dynamodb-app:latest .
docker tag fastapi-dynamodb-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fastapi-dynamodb-app:latest

# 2. Update service (force new deployment)
aws ecs update-service \
    --cluster fastapi-cluster \
    --service fastapi-service \
    --force-new-deployment
```

---

## Cleanup (When Done)

```bash
# Delete service
aws ecs delete-service --cluster fastapi-cluster --service fastapi-service --force

# Delete cluster (after service is deleted)
aws ecs delete-cluster --cluster fastapi-cluster

# Deregister task definition
aws ecs deregister-task-definition --task-definition fastapi-dynamodb-app:1

# Delete ECR repository
aws ecr delete-repository --repository-name fastapi-dynamodb-app --force

# Terminate EC2 instances (via console)
# Delete DynamoDB table (if not needed)
aws dynamodb delete-table --table-name Users
```

---

## Troubleshooting

### Container won't start:
1. Check CloudWatch logs: `/ecs/fastapi-dynamodb-app`
2. Verify IAM roles are attached correctly
3. Check security group allows port 80

### Can't access API:
1. Verify EC2 security group allows inbound port 80
2. Check task is RUNNING in ECS
3. Use EC2 public IP (not private IP)

### DynamoDB access denied:
1. Verify IAM task role has DynamoDB permissions
2. Check AWS credentials in task definition
3. Verify DynamoDB table exists and region matches

---

Need help? Check AWS Free Tier usage: https://console.aws.amazon.com/billing/home#/freetier
