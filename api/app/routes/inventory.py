"""Inventory endpoints"""
import uuid
from datetime import date, datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel

from app.middleware.auth import AuthContext, get_current_user
from app.db.firestore import get_firestore_client

router = APIRouter()


class InventoryItemCreate(BaseModel):
    name: str
    quantity: float
    unit: str  # g, kg, ml, l, count, oz, cup, tbsp, tsp
    best_before: date
    barcode: Optional[str] = None


class UpdateQuantityRequest(BaseModel):
    quantity: float


class InventoryItemResponse(BaseModel):
    item_id: str
    name: str
    quantity: float
    unit: str
    best_before: date
    expiring_soon: bool
    added_at: datetime


class PaginationInfo(BaseModel):
    page: int
    per_page: int
    total: int


class InventoryListResponse(BaseModel):
    items: List[InventoryItemResponse]
    pagination: PaginationInfo


class DashboardResponse(BaseModel):
    low_stock: List[InventoryItemResponse]
    expiring_soon: List[InventoryItemResponse]
    last_updated: datetime


def _to_response(item: dict) -> InventoryItemResponse:
    """Convert a Firestore item dict to InventoryItemResponse."""
    best_before = item["best_before"]
    if isinstance(best_before, datetime):
        best_before = best_before.date()
    return InventoryItemResponse(
        item_id=item["item_id"],
        name=item["name"],
        quantity=item["quantity"],
        unit=item["unit"],
        best_before=best_before,
        expiring_soon=item.get("expiring_soon", False),
        added_at=item["added_at"],
    )


@router.post(
    "/{kingdom_id}/inventory",
    response_model=InventoryItemResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_inventory(
    kingdom_id: str,
    request: InventoryItemCreate,
    auth: AuthContext = Depends(get_current_user),
):
    """Add an inventory item to a kingdom."""
    db = get_firestore_client()
    item_id = str(uuid.uuid4())

    item = db.add_inventory_item(
        kingdom_id=kingdom_id,
        item_id=item_id,
        name=request.name,
        quantity=request.quantity,
        unit=request.unit,
        best_before=request.best_before,
        barcode=request.barcode,
    )

    return _to_response(item)


@router.get("/{kingdom_id}/inventory", response_model=InventoryListResponse)
async def list_inventory(
    kingdom_id: str,
    page: int = Query(default=1, ge=1),
    auth: AuthContext = Depends(get_current_user),
):
    """List inventory items for a kingdom with pagination."""
    db = get_firestore_client()
    items, total = db.list_inventory_items(kingdom_id=kingdom_id, page=page)

    return InventoryListResponse(
        items=[_to_response(item) for item in items],
        pagination=PaginationInfo(page=page, per_page=50, total=total),
    )


@router.get("/{kingdom_id}/dashboard", response_model=DashboardResponse)
async def get_dashboard(
    kingdom_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """Get dashboard summary with low-stock and expiring-soon items."""
    db = get_firestore_client()
    expiring = db.get_expiring_soon_items(kingdom_id)
    low_stock = db.get_low_stock_items(kingdom_id)

    return DashboardResponse(
        low_stock=[_to_response(item) for item in low_stock],
        expiring_soon=[_to_response(item) for item in expiring],
        last_updated=datetime.now(timezone.utc),
    )


@router.patch("/{kingdom_id}/inventory/{item_id}", response_model=InventoryItemResponse)
async def update_inventory(
    kingdom_id: str,
    item_id: str,
    request: UpdateQuantityRequest,
    auth: AuthContext = Depends(get_current_user),
):
    """Update the quantity of an inventory item."""
    db = get_firestore_client()
    item = db.get_inventory_item(item_id)

    if not item or item.get("kingdom_id") != kingdom_id or item.get("is_deleted"):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )

    db.update_inventory_item(item_id=item_id, quantity=request.quantity)
    item["quantity"] = request.quantity

    return _to_response(item)


@router.delete(
    "/{kingdom_id}/inventory/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_inventory(
    kingdom_id: str,
    item_id: str,
    auth: AuthContext = Depends(get_current_user),
):
    """Soft-delete an inventory item."""
    db = get_firestore_client()
    item = db.get_inventory_item(item_id)

    if not item or item.get("kingdom_id") != kingdom_id or item.get("is_deleted"):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )

    db.delete_inventory_item(item_id)
    return None

