"""Allergy endpoints"""
import uuid
from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.middleware.auth import AuthContext, get_current_user
from app.db.firestore import get_firestore_client

router = APIRouter()


class AllergenCreate(BaseModel):
    allergen_name: str
    severity: str  # mild, moderate, severe, life-threatening


class UpdateSeverityRequest(BaseModel):
    severity: str


class AllergenResponse(BaseModel):
    allergen_id: str
    allergen_name: str
    severity: str
    added_at: datetime


@router.post(
    "/{member_id}/allergies",
    response_model=AllergenResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_allergen(
    member_id: str,
    request: AllergenCreate,
    auth: AuthContext = Depends(get_current_user),
):
    """Add an allergen for a member."""
    db = get_firestore_client()
    allergen_id = str(uuid.uuid4())

    allergen = db.add_allergen(
        allergen_id=allergen_id,
        member_id=member_id,
        allergen_name=request.allergen_name,
        severity=request.severity,
    )

    return AllergenResponse(
        allergen_id=allergen["allergen_id"],
        allergen_name=allergen["allergen_name"],
        severity=allergen["severity"],
        added_at=allergen["added_at"],
    )


@router.get("/{member_id}/allergies", response_model=List[AllergenResponse])
async def list_allergies(
    member_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """List all allergens for a member."""
    db = get_firestore_client()
    allergens = db.list_allergens(member_id)

    return [
        AllergenResponse(
            allergen_id=a["allergen_id"],
            allergen_name=a["allergen_name"],
            severity=a["severity"],
            added_at=a["added_at"],
        )
        for a in allergens
    ]


@router.patch(
    "/{member_id}/allergies/{allergen_id}",
    response_model=AllergenResponse,
)
async def update_allergen(
    member_id: str,
    allergen_id: str,
    request: UpdateSeverityRequest,
    auth: AuthContext = Depends(get_current_user),
):
    """Update the severity of an allergen."""
    db = get_firestore_client()
    allergen = db.get_allergen(allergen_id)

    if not allergen or allergen.get("member_id") != member_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Allergen not found",
        )

    db.update_allergen(allergen_id=allergen_id, severity=request.severity)
    allergen["severity"] = request.severity

    return AllergenResponse(
        allergen_id=allergen["allergen_id"],
        allergen_name=allergen["allergen_name"],
        severity=allergen["severity"],
        added_at=allergen["added_at"],
    )


@router.delete(
    "/{member_id}/allergies/{allergen_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_allergen(
    member_id: str,
    allergen_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """Delete an allergen record."""
    db = get_firestore_client()
    allergen = db.get_allergen(allergen_id)

    if not allergen or allergen.get("member_id") != member_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Allergen not found",
        )

    db.delete_allergen(allergen_id)
    return None

