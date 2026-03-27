"""
Firestore integration for user, token, kingdom, inventory, and allergy management.
"""
import uuid
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Optional

from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

from app.config import settings


class FirestoreClient:
    """Firestore database client for all domain operations."""

    def __init__(self):
        """Initialize Firestore client."""
        self.db = firestore.Client(project=settings.FIRESTORE_PROJECT_ID)
        self.users_collection = settings.FIRESTORE_USERS_COLLECTION
        self.tokens_collection = settings.FIRESTORE_REFRESH_TOKENS_COLLECTION
        self.audit_collection = settings.FIRESTORE_AUDIT_COLLECTION
        self.kingdoms_collection = settings.FIRESTORE_KINGDOMS_COLLECTION
        self.inventory_collection = settings.FIRESTORE_INVENTORY_COLLECTION
        self.allergies_collection = settings.FIRESTORE_ALLERGIES_COLLECTION

    # ==================== User Operations ====================

    def create_user(
        self,
        user_id: str,
        email: str,
        password_hash: str,
        kingdom_id: str = "default-kingdom",
        role: str = "user",
    ) -> Dict:
        """Create a new user in Firestore.

        Args:
            user_id: Unique user identifier.
            email: User email address.
            password_hash: Hashed password.
            kingdom_id: Kingdom/organization ID.
            role: User role for RBAC.

        Returns:
            Dict: Created user data.

        Raises:
            ValueError: If user with email already exists.
        """
        # Check if user with this email already exists
        existing = self.db.collection(self.users_collection).where(
            filter=FieldFilter("email", "==", email.lower())
        ).limit(1).stream()

        if any(existing):
            raise ValueError(f"User with email {email} already exists")

        user_data = {
            "user_id": user_id,
            "email": email.lower(),
            "password_hash": password_hash,
            "kingdom_id": kingdom_id,
            "role": role,
            "created_at": datetime.now(timezone.utc),
            "updated_at": datetime.now(timezone.utc),
            "is_active": True,
        }

        self.db.collection(self.users_collection).document(user_id).set(user_data)
        return user_data

    def get_user_by_id(self, user_id: str) -> Optional[Dict]:
        """Retrieve user by ID.

        Args:
            user_id: Unique user identifier.

        Returns:
            Optional[Dict]: User data or None if not found.
        """
        doc = self.db.collection(self.users_collection).document(user_id).get()
        
        if not doc.exists:
            return None
        
        return doc.to_dict()

    def get_user_by_email(self, email: str) -> Optional[Dict]:
        """Retrieve user by email address.

        Args:
            email: User email address.

        Returns:
            Optional[Dict]: User data or None if not found.
        """
        docs = self.db.collection(self.users_collection).where(
            filter=FieldFilter("email", "==", email.lower())
        ).limit(1).stream()

        for doc in docs:
            return doc.to_dict()
        
        return None

    def update_user(self, user_id: str, update_data: Dict) -> Dict:
        """Update user data.

        Args:
            user_id: Unique user identifier.
            update_data: Dictionary of fields to update.

        Returns:
            Dict: Updated user data.

        Raises:
            ValueError: If user not found.
        """
        user = self.get_user_by_id(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")

        update_data["updated_at"] = datetime.now(timezone.utc)
        self.db.collection(self.users_collection).document(user_id).update(update_data)
        
        return {**user, **update_data}

    def deactivate_user(self, user_id: str) -> None:
        """Deactivate a user account.

        Args:
            user_id: Unique user identifier.

        Raises:
            ValueError: If user not found.
        """
        user = self.get_user_by_id(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")
        
        self.db.collection(self.users_collection).document(user_id).update({
            "is_active": False,
            "updated_at": datetime.now(timezone.utc),
        })

    # ==================== Refresh Token Operations ====================

    def store_refresh_token(
        self,
        token_id: str,
        user_id: str,
        refresh_token: str,
        expires_at: datetime,
    ) -> Dict:
        """Store a refresh token in Firestore.

        Args:
            token_id: JWT ID (jti) from token.
            user_id: User ID associated with token.
            refresh_token: The actual refresh token.
            expires_at: Token expiration datetime.

        Returns:
            Dict: Stored token record.
        """
        token_data = {
            "token_id": token_id,
            "user_id": user_id,
            "refresh_token": refresh_token,
            "expires_at": expires_at,
            "created_at": datetime.now(timezone.utc),
            "is_blacklisted": False,
        }

        self.db.collection(self.tokens_collection).document(token_id).set(token_data)
        return token_data

    def get_refresh_token(self, token_id: str) -> Optional[Dict]:
        """Retrieve a refresh token.

        Args:
            token_id: JWT ID (jti) of the token.

        Returns:
            Optional[Dict]: Token data or None if not found.
        """
        doc = self.db.collection(self.tokens_collection).document(token_id).get()
        
        if not doc.exists:
            return None
        
        return doc.to_dict()

    def blacklist_refresh_token(self, token_id: str) -> None:
        """Blacklist a refresh token (add to logout/invalidation list).

        Args:
            token_id: JWT ID (jti) of the token to blacklist.
        """
        self.db.collection(self.tokens_collection).document(token_id).update({
            "is_blacklisted": True,
            "blacklisted_at": datetime.now(timezone.utc),
        })

    def is_token_blacklisted(self, token_id: str) -> bool:
        """Check if a token is blacklisted.

        Args:
            token_id: JWT ID (jti) of the token.

        Returns:
            bool: True if blacklisted, False otherwise.
        """
        token = self.get_refresh_token(token_id)
        
        if not token:
            return False
        
        return token.get("is_blacklisted", False)

    def cleanup_expired_tokens(self) -> int:
        """Remove expired tokens from database.

        Returns:
            int: Number of tokens removed.
        """
        now = datetime.now(timezone.utc)
        batch = self.db.batch()
        
        docs = self.db.collection(self.tokens_collection).where(
            filter=FieldFilter("expires_at", "<", now)
        ).stream()

        count = 0
        for doc in docs:
            batch.delete(doc.reference)
            count += 1

        batch.commit()
        return count

    # ==================== Audit Logging ====================

    def log_auth_attempt(
        self,
        event_type: str,
        email: Optional[str] = None,
        user_id: Optional[str] = None,
        success: bool = False,
        reason: Optional[str] = None,
    ) -> None:
        """Log authentication attempt to audit collection.

        Args:
            event_type: Type of event (signup, login, logout, failed_login, etc).
            email: Email involved in the attempt.
            user_id: User ID (if applicable).
            success: Whether the attempt was successful.
            reason: Reason for failure (if applicable).
        """
        audit_data = {
            "event_type": event_type,
            "email": (email or "").lower(),
            "user_id": user_id,
            "success": success,
            "reason": reason,
            "timestamp": datetime.now(timezone.utc),
            "ip_address": None,  # Could be populated from request context
        }

        self.db.collection(self.audit_collection).add(audit_data)

    def get_user_audit_logs(
        self,
        user_id: str,
        limit: int = 50,
    ) -> List[Dict]:
        """Retrieve audit logs for a specific user.

        Args:
            user_id: User ID to retrieve logs for.
            limit: Maximum number of logs to return.

        Returns:
            List[Dict]: List of audit log entries.
        """
        docs = self.db.collection(self.audit_collection).where(
            filter=FieldFilter("user_id", "==", user_id)
        ).order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()

        return [doc.to_dict() for doc in docs]

    # ==================== User-keyed Refresh Token Methods ====================

    def upsert_user_refresh_token(
        self, user_id: str, refresh_token: str, expires_at: datetime
    ) -> None:
        """Store or replace active refresh token for a user (document keyed by user_id)."""
        token_data = {
            "user_id": user_id,
            "refresh_token": refresh_token,
            "expires_at": expires_at,
            "created_at": datetime.now(timezone.utc),
            "is_blacklisted": False,
        }
        self.db.collection(self.tokens_collection).document(f"user_{user_id}").set(token_data)

    def get_user_refresh_token(self, user_id: str) -> Optional[Dict]:
        """Get active (non-expired, non-blacklisted) refresh token record for a user."""
        doc = self.db.collection(self.tokens_collection).document(f"user_{user_id}").get()
        if not doc.exists:
            return None
        data = doc.to_dict()
        if data.get("is_blacklisted"):
            return None
        expires_at = data.get("expires_at")
        if expires_at and datetime.now(timezone.utc) > expires_at:
            return None
        return data

    def revoke_user_refresh_token(self, user_id: str) -> None:
        """Delete the refresh token record for a user."""
        self.db.collection(self.tokens_collection).document(f"user_{user_id}").delete()

    # ==================== Kingdom Operations ====================

    def create_kingdom(
        self,
        kingdom_id: str,
        name: str,
        mode: str,
        created_by: str,
        timezone_str: str = "UTC",
    ) -> Dict:
        """Create a new kingdom."""
        now = datetime.now(timezone.utc)
        kingdom_data = {
            "kingdom_id": kingdom_id,
            "name": name,
            "mode": mode,
            "created_by": created_by,
            "timezone": timezone_str,
            "created_at": now,
            "updated_at": now,
        }
        self.db.collection(self.kingdoms_collection).document(kingdom_id).set(kingdom_data)
        return kingdom_data

    def get_kingdom(self, kingdom_id: str) -> Optional[Dict]:
        """Retrieve a kingdom by ID."""
        doc = self.db.collection(self.kingdoms_collection).document(kingdom_id).get()
        return doc.to_dict() if doc.exists else None

    def add_kingdom_member(self, kingdom_id: str, user_id: str, role: str = "member") -> None:
        """Add a member to a kingdom subcollection."""
        now = datetime.now(timezone.utc)
        member_data = {
            "user_id": user_id,
            "kingdom_id": kingdom_id,
            "role": role,
            "joined_at": now,
        }
        self.db.collection(self.kingdoms_collection).document(kingdom_id) \
            .collection("members").document(user_id).set(member_data)

    def get_kingdom_members(self, kingdom_id: str) -> List[Dict]:
        """List all members of a kingdom."""
        docs = self.db.collection(self.kingdoms_collection).document(kingdom_id) \
            .collection("members").stream()
        return [doc.to_dict() for doc in docs]

    def assign_member_role(self, kingdom_id: str, user_id: str, role: str) -> None:
        """Update a member's role in a kingdom."""
        self.db.collection(self.kingdoms_collection).document(kingdom_id) \
            .collection("members").document(user_id).update({
                "role": role,
                "updated_at": datetime.now(timezone.utc),
            })

    # ==================== Inventory Operations ====================

    def add_inventory_item(
        self,
        kingdom_id: str,
        item_id: str,
        name: str,
        quantity: float,
        unit: str,
        best_before,
        barcode: Optional[str] = None,
    ) -> Dict:
        """Add an inventory item for a kingdom."""
        from datetime import date as date_type
        now = datetime.now(timezone.utc)
        today = now.date()
        delta = (best_before - today).days if isinstance(best_before, date_type) else 999
        expiring_soon = delta <= 3

        # Normalise best_before to a UTC datetime for Firestore storage
        if isinstance(best_before, date_type) and not isinstance(best_before, datetime):
            best_before_dt = datetime(best_before.year, best_before.month, best_before.day,
                                      tzinfo=timezone.utc)
        else:
            best_before_dt = best_before

        item_data = {
            "item_id": item_id,
            "kingdom_id": kingdom_id,
            "name": name,
            "quantity": quantity,
            "unit": unit,
            "best_before": best_before_dt,
            "barcode": barcode,
            "expiring_soon": expiring_soon,
            "is_deleted": False,
            "added_at": now,
            "updated_at": now,
        }
        self.db.collection(self.inventory_collection).document(item_id).set(item_data)
        return item_data

    def get_inventory_item(self, item_id: str) -> Optional[Dict]:
        """Retrieve a single inventory item."""
        doc = self.db.collection(self.inventory_collection).document(item_id).get()
        return doc.to_dict() if doc.exists else None

    def list_inventory_items(
        self, kingdom_id: str, page: int = 1, per_page: int = 50
    ) -> tuple:
        """List non-deleted inventory items for a kingdom with pagination."""
        query = self.db.collection(self.inventory_collection) \
            .where(filter=FieldFilter("kingdom_id", "==", kingdom_id)) \
            .where(filter=FieldFilter("is_deleted", "==", False)) \
            .order_by("added_at", direction=firestore.Query.DESCENDING)

        all_docs = list(query.stream())
        total = len(all_docs)
        start = (page - 1) * per_page
        page_docs = all_docs[start : start + per_page]
        return [doc.to_dict() for doc in page_docs], total

    def update_inventory_item(self, item_id: str, quantity: float) -> None:
        """Update the quantity of an inventory item."""
        self.db.collection(self.inventory_collection).document(item_id).update({
            "quantity": quantity,
            "updated_at": datetime.now(timezone.utc),
        })

    def delete_inventory_item(self, item_id: str) -> None:
        """Soft-delete an inventory item."""
        self.db.collection(self.inventory_collection).document(item_id).update({
            "is_deleted": True,
            "updated_at": datetime.now(timezone.utc),
        })

    def get_expiring_soon_items(self, kingdom_id: str, days: int = 3) -> List[Dict]:
        """Get items expiring within the next N days."""
        now = datetime.now(timezone.utc)
        today_dt = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)
        cutoff_dt = today_dt + timedelta(days=days)

        docs = self.db.collection(self.inventory_collection) \
            .where(filter=FieldFilter("kingdom_id", "==", kingdom_id)) \
            .where(filter=FieldFilter("is_deleted", "==", False)) \
            .where(filter=FieldFilter("best_before", ">=", today_dt)) \
            .where(filter=FieldFilter("best_before", "<=", cutoff_dt)) \
            .stream()
        return [doc.to_dict() for doc in docs]

    def get_low_stock_items(self, kingdom_id: str, threshold: float = 1.0) -> List[Dict]:
        """Get items with quantity at or below the threshold."""
        docs = self.db.collection(self.inventory_collection) \
            .where(filter=FieldFilter("kingdom_id", "==", kingdom_id)) \
            .where(filter=FieldFilter("is_deleted", "==", False)) \
            .where(filter=FieldFilter("quantity", "<=", threshold)) \
            .stream()
        return [doc.to_dict() for doc in docs]

    # ==================== Allergy Operations ====================

    def add_allergen(
        self, allergen_id: str, member_id: str, allergen_name: str, severity: str
    ) -> Dict:
        """Create an allergen entry for a member."""
        now = datetime.now(timezone.utc)
        allergen_data = {
            "allergen_id": allergen_id,
            "member_id": member_id,
            "allergen_name": allergen_name,
            "severity": severity,
            "added_at": now,
        }
        self.db.collection(self.allergies_collection).document(allergen_id).set(allergen_data)
        return allergen_data

    def get_allergen(self, allergen_id: str) -> Optional[Dict]:
        """Retrieve a single allergen record."""
        doc = self.db.collection(self.allergies_collection).document(allergen_id).get()
        return doc.to_dict() if doc.exists else None

    def list_allergens(self, member_id: str) -> List[Dict]:
        """List all allergens for a member."""
        docs = self.db.collection(self.allergies_collection) \
            .where(filter=FieldFilter("member_id", "==", member_id)) \
            .order_by("added_at", direction=firestore.Query.DESCENDING) \
            .stream()
        return [doc.to_dict() for doc in docs]

    def update_allergen(self, allergen_id: str, severity: str) -> None:
        """Update an allergen's severity."""
        self.db.collection(self.allergies_collection).document(allergen_id).update({
            "severity": severity,
            "updated_at": datetime.now(timezone.utc),
        })

    def delete_allergen(self, allergen_id: str) -> None:
        """Permanently delete an allergen record."""
        self.db.collection(self.allergies_collection).document(allergen_id).delete()


# ==================== Module-level singleton ====================

_firestore_client: Optional[FirestoreClient] = None


def get_firestore_client() -> FirestoreClient:
    """Get or create the Firestore client singleton."""
    global _firestore_client
    if _firestore_client is None:
        _firestore_client = FirestoreClient()
    return _firestore_client


def init_firestore() -> None:
    """Initialize the Firestore connection at application startup."""
    get_firestore_client()


# ==================== Module-level helper functions for routes ====================

def create_user(email: str, password_hash: str, kingdom_id: str = "default-kingdom") -> str:
    """Create a user and return the generated user_id."""
    user_id = str(uuid.uuid4())
    get_firestore_client().create_user(user_id, email, password_hash, kingdom_id)
    return user_id


def get_user_by_email(email: str) -> Optional[Dict]:
    """Look up a user by email address."""
    return get_firestore_client().get_user_by_email(email)


def create_refresh_token_record(user_id: str, refresh_token: str) -> None:
    """Persist a refresh token for a user, replacing any previous one."""
    expires_at = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    get_firestore_client().upsert_user_refresh_token(user_id, refresh_token, expires_at)


def get_refresh_token_record(user_id: str) -> Optional[Dict]:
    """Retrieve the active refresh token record for a user."""
    return get_firestore_client().get_user_refresh_token(user_id)


def revoke_refresh_token(user_id: str) -> None:
    """Revoke (delete) the refresh token for a user."""
    get_firestore_client().revoke_user_refresh_token(user_id)


def log_auth_attempt(
    event_type: str,
    email: Optional[str] = None,
    user_id: Optional[str] = None,
    success: bool = False,
    reason: Optional[str] = None,
) -> None:
    """Log an authentication event to the audit collection."""
    get_firestore_client().log_auth_attempt(
        event_type=event_type,
        email=email,
        user_id=user_id,
        success=success,
        reason=reason,
    )
