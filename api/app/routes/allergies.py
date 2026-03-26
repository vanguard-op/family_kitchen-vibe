"""Allergy endpoints"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List
from datetime import datetime

router = APIRouter()


class AllergenCreate(BaseModel):
    """Create allergen request"""
    allergen_name: str
    severity: str  # mild, moderate, severe


class AllergenResponse(BaseModel):
    """Allergen response"""
    allergen_id: str
    allergen_name: str
    severity: str
    added_at: datetime


@router.post("/{member_id}/allergies", response_model=AllergenResponse, status_code=status.HTTP_201_CREATED)
async def add_allergen(member_id: str, request: AllergenCreate):
    """Add allergen for member"""
    # TODO: Implement add allergen
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Add allergen not yet implemented"
    )


@router.get("/{member_id}/allergies", response_model=List[AllergenResponse])
async def list_allergies(member_id: str):
    """List member allergies"""
    # TODO: Implement list allergies
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="List allergies not yet implemented"
    )


@router.patch("/{member_id}/allergies/{allergen_id}")
async def update_allergen(member_id: str, allergen_id: str, severity: str):
    """Update allergen severity"""
    # TODO: Implement update allergen
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Update allergen not yet implemented"
    )


@router.delete("/{member_id}/allergies/{allergen_id}")
async def delete_allergen(member_id: str, allergen_id: str):
    """Delete allergen"""
    # TODO: Implement delete allergen
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Delete allergen not yet implemented"
    )
