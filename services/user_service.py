from db.dynamodb import get_users_table
from models.user import UserCreate, UserUpdate
from botocore.exceptions import ClientError
from typing import List, Optional


class UserService:

    @staticmethod
    def create_user(user: UserCreate):
        """Create a new user in DynamoDB"""
        table = get_users_table()
        item = user.dict()
        
        try:
            table.put_item(
                Item=item,
                ConditionExpression="attribute_not_exists(user_id)"
            )
            return item
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                raise ValueError(f"User with id {user.user_id} already exists")
            raise

    @staticmethod
    def get_user(user_id: str):
        """Get a user by user_id"""
        table = get_users_table()
        
        try:
            response = table.get_item(Key={"user_id": user_id})
            return response.get("Item")
        except ClientError:
            return None

    @staticmethod
    def list_users(limit: int = 100):
        """List all users with pagination support"""
        table = get_users_table()
        
        try:
            response = table.scan(Limit=limit)
            return response.get("Items", [])
        except ClientError:
            return []

    @staticmethod
    def update_user(user_id: str, user: UserUpdate):
        """Update user details"""
        table = get_users_table()
        
        update_expression = []
        expression_values = {}
        expression_names = {}
        
        if user.name is not None:
            update_expression.append("#n = :name")
            expression_values[":name"] = user.name
            expression_names["#n"] = "name"
        
        if user.email is not None:
            update_expression.append("#e = :email")
            expression_values[":email"] = user.email
            expression_names["#e"] = "email"
        
        if not update_expression:
            return None
        
        try:
            response = table.update_item(
                Key={"user_id": user_id},
                UpdateExpression="SET " + ", ".join(update_expression),
                ExpressionAttributeNames=expression_names,
                ExpressionAttributeValues=expression_values,
                ConditionExpression="attribute_exists(user_id)",
                ReturnValues="ALL_NEW"
            )
            return response.get("Attributes")
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                raise ValueError(f"User with id {user_id} does not exist")
            raise

    @staticmethod
    def delete_user(user_id: str):
        """Delete a user by user_id"""
        table = get_users_table()
        
        try:
            table.delete_item(
                Key={"user_id": user_id},
                ConditionExpression="attribute_exists(user_id)"
            )
            return {"deleted": True}
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                raise ValueError(f"User with id {user_id} does not exist")
            raise
