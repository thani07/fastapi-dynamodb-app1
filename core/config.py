from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    DYNAMODB_USERS_TABLE: str = "Users"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
