"""Inventory endpoints"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List
from datetime import date, datetime

router = APIRouter()


class InventoryItemCreate(BaseModel):
    """Create inventory item request"""
    name: str
    quantity: float
    unit: str  # g, kg, ml, l, count, oz, cup, tbsp, tsp
    best_before: date
    barcode: Optional[str] = None


class InventoryItemResponse(BaseModel):
    """Inventory item response"""
    item_id: str
    name: str
    quantity: float
    unit: str
    best_before: date
    expiring_soon: bool
    added_at: datetime


class DashboardResponse(BaseModel):
    """Dashboard response with low stock and expiring soon"""
    low_stock: List[InventoryItemResponse]
    expiring_soon: List[InventoryItemResponse]
    last_updated: datetime


@router.post("/{kingdom_id}/inventory", response_model=InventoryItemResponse, status_code=status.HTTP_201_CREATED)
async def add_inventory(kingdom_id: str, request: InventoryItemCreate):
    """Add inventory item"""
    # TODO: Implement add inventory
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Add inventory not yet implemented"
    )


@router.get("/{kingdom_id}/inventory", response_model=List[InventoryItemResponse])
async def list_inventory(kingdom_id: str, page: int = 1):
    """List inventory items"""
    # TODO: Implement list inventory
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="List inventory not yet implemented"
    )


@router.get("/{kingdom_id}/dashboard", response_model=DashboardResponse)
async def get_dashboard(kingdom_id: str):
    """Get dashboard with low stock and expiring soon"""
    # TODO: Implement dashboard
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Dashboard not yet implemented"
    )


@router.patch("/{kingdom_id}/inventory/{item_id}")
async def update_inventory(kingdom_id: str, item_id: str, quantity: float):
    """Update inventory item"""
    # TODO: Implement update inventory
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Update inventory not yet implemented"
    )


@router.delete("/{kingdom_id}/inventory/{item_id}")
async def delete_inventory(kingdom_id: str, item_id: str):
    """Delete (archive) inventory item"""
    # TODO: Implement delete inventory
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Delete inventory not yet implemented"
    )
