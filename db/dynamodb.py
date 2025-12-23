import boto3
from core.config import settings


def get_dynamodb_resource():
    """Create and return a DynamoDB resource with AWS credentials"""
    session_kwargs = {
        "region_name": settings.AWS_REGION
    }
    
    if settings.AWS_ACCESS_KEY_ID and settings.AWS_SECRET_ACCESS_KEY:
        session_kwargs.update({
            "aws_access_key_id": settings.AWS_ACCESS_KEY_ID,
            "aws_secret_access_key": settings.AWS_SECRET_ACCESS_KEY
        })
    
    return boto3.resource("dynamodb", **session_kwargs)


def get_users_table():
    """Return the Users table from DynamoDB"""
    dynamodb = get_dynamodb_resource()
    return dynamodb.Table(settings.DYNAMODB_USERS_TABLE)
