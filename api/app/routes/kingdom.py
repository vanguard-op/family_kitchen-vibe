"""Kingdom endpoints"""
import uuid
from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.middleware.auth import AuthContext, get_current_user
from app.db.firestore import get_firestore_client

router = APIRouter()


class KingdomCreate(BaseModel):
    name: str
    mode: str  # "solo" or "family"
    timezone: str = "UTC"


class KingdomResponse(BaseModel):
    kingdom_id: str
    name: str
    mode: str
    created_by: str
    timezone: str = "UTC"
    member_count: int
    created_at: datetime


class MemberResponse(BaseModel):
    user_id: str
    role: str
    joined_at: datetime


class MemberListResponse(BaseModel):
    members: List[MemberResponse]


class AssignRoleRequest(BaseModel):
    role: str


class AssignRoleResponse(BaseModel):
    member_id: str
    role: str
    changed_at: datetime


@router.post("/", response_model=KingdomResponse, status_code=status.HTTP_201_CREATED)
async def create_kingdom(
    request: KingdomCreate,
    auth: AuthContext = Depends(get_current_user),
):
    """Create a new kingdom. The authenticated user becomes the owner."""
    db = get_firestore_client()
    kingdom_id = str(uuid.uuid4())

    kingdom = db.create_kingdom(
        kingdom_id=kingdom_id,
        name=request.name,
        mode=request.mode,
        created_by=auth.user_id,
        timezone_str=request.timezone,
    )

    # Add creator as owner member
    db.add_kingdom_member(kingdom_id=kingdom_id, user_id=auth.user_id, role="owner")

    # Update user's kingdom_id in their profile
    db.update_user(auth.user_id, {"kingdom_id": kingdom_id})

    return KingdomResponse(
        kingdom_id=kingdom["kingdom_id"],
        name=kingdom["name"],
        mode=kingdom["mode"],
        created_by=kingdom["created_by"],
        timezone=kingdom["timezone"],
        member_count=1,
        created_at=kingdom["created_at"],
    )


@router.get("/{kingdom_id}", response_model=KingdomResponse)
async def get_kingdom(
    kingdom_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """Get kingdom details."""
    db = get_firestore_client()
    kingdom = db.get_kingdom(kingdom_id)

    if not kingdom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Kingdom not found",
        )

    members = db.get_kingdom_members(kingdom_id)

    return KingdomResponse(
        kingdom_id=kingdom["kingdom_id"],
        name=kingdom["name"],
        mode=kingdom["mode"],
        created_by=kingdom["created_by"],
        timezone=kingdom.get("timezone", "UTC"),
        member_count=len(members),
        created_at=kingdom["created_at"],
    )


@router.get("/{kingdom_id}/members", response_model=MemberListResponse)
async def list_members(
    kingdom_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """List all members of a kingdom."""
    db = get_firestore_client()
    kingdom = db.get_kingdom(kingdom_id)

    if not kingdom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Kingdom not found",
        )

    members_data = db.get_kingdom_members(kingdom_id)

    return MemberListResponse(
        members=[
            MemberResponse(
                user_id=m["user_id"],
                role=m["role"],
                joined_at=m["joined_at"],
            )
            for m in members_data
        ]
    )


@router.post(
    "/{kingdom_id}/members/{member_id}/assign-role",
    response_model=AssignRoleResponse,
)
async def assign_role(
    kingdom_id: str,
    member_id: str,
    request: AssignRoleRequest,
    auth: AuthContext = Depends(get_current_user),
):
    """Assign a role to a kingdom member. Only the kingdom owner may do this."""
    db = get_firestore_client()
    kingdom = db.get_kingdom(kingdom_id)

    if not kingdom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Kingdom not found",
        )

    if kingdom["created_by"] != auth.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the kingdom owner can assign roles",
        )

    try:
        db.assign_member_role(kingdom_id=kingdom_id, user_id=member_id, role=request.role)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Member not found in this kingdom",
        )

    return AssignRoleResponse(
        member_id=member_id,
        role=request.role,
        changed_at=datetime.now(timezone.utc),
    )

