from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional


class UserBase(BaseModel):
    """用户基础模式"""
    email: EmailStr
    username: str


class UserCreate(UserBase):
    """用户创建模式"""
    password: str


class UserLogin(BaseModel):
    """用户登录模式"""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """用户响应模式"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """令牌响应模式"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse


class RefreshTokenRequest(BaseModel):
    """刷新令牌请求"""
    refresh_token: str


class MessageResponse(BaseModel):
    """消息响应模式"""
    message: str
