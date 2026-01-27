from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..schemas.user import (
    UserCreate, 
    UserLogin, 
    TokenResponse, 
    RefreshTokenRequest
)
from ..services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["认证"])


@router.post("/register", response_model=TokenResponse)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """用户注册"""
    return AuthService.register(db, user_data)


@router.post("/login", response_model=TokenResponse)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    """用户登录"""
    return AuthService.login(db, login_data)


@router.post("/refresh")
def refresh_token(data: RefreshTokenRequest, db: Session = Depends(get_db)):
    """刷新访问令牌"""
    return AuthService.refresh_token(db, data.refresh_token)
