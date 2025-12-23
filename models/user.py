from pydantic import BaseModel, Field
from typing import Optional


class UserBase(BaseModel):
    name: str = Field(..., example="Appu")
    email: str = Field(..., example="appu@email.com")


class UserCreate(UserBase):
    user_id: str = Field(..., example="user_001")


class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None


class UserResponse(UserCreate):
    class Config:
        orm_mode = True
