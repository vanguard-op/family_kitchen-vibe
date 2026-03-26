"""Kingdom endpoints"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

router = APIRouter()


class KingdomCreate(BaseModel):
    """Create kingdom request"""
    name: str
    mode: str  # "solo" or "family"
    member_ids: Optional[List[str]] = None


class KingdomResponse(BaseModel):
    """Kingdom response model"""
    kingdom_id: str
    name: str
    mode: str
    created_by: str
    timezone: str = "UTC"
    member_count: int
    created_at: datetime


@router.post("/", response_model=KingdomResponse, status_code=status.HTTP_201_CREATED)
async def create_kingdom(request: KingdomCreate):
    """Create a new kingdom"""
    # TODO: Implement kingdom creation
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Kingdom creation not yet implemented"
    )


@router.get("/{kingdom_id}", response_model=KingdomResponse)
async def get_kingdom(kingdom_id: str):
    """Get kingdom details"""
    # TODO: Implement get kingdom
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Get kingdom not yet implemented"
    )


@router.get("/{kingdom_id}/members")
async def list_members(kingdom_id: str):
    """List kingdom members"""
    # TODO: Implement list members
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="List members not yet implemented"
    )


@router.post("/{kingdom_id}/members/{member_id}/assign-role")
async def assign_role(kingdom_id: str, member_id: str, role: str):
    """Assign role to member"""
    # TODO: Implement assign role
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Assign role not yet implemented"
    )
