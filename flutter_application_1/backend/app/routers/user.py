from fastapi import APIRouter, Depends
from ..core.security import get_current_user
from ..models.user import User
from ..schemas.user import UserResponse

router = APIRouter(prefix="/user", tags=["用户"])


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """获取当前用户信息"""
    return current_user
