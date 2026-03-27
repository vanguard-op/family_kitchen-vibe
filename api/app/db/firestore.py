"""
Firestore integration for user and token management.
"""
from datetime import datetime, timezone
from typing import Dict, List, Optional

from google.cloud import firestore
from google.cloud.firestore import DocumentSnapshot, Query

from app.config import get_settings


class FirestoreClient:
    """Firestore database client for user and token operations."""

    def __init__(self):
        """Initialize Firestore client."""
        settings = get_settings()
        self.db = firestore.Client(project=settings.FIRESTORE_PROJECT_ID)
        self.users_collection = settings.FIRESTORE_USERS_COLLECTION
        self.tokens_collection = settings.FIRESTORE_REFRESH_TOKENS_COLLECTION
        self.audit_collection = settings.FIRESTORE_AUDIT_COLLECTION

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
            "email", "==", email.lower()
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
            "email", "==", email.lower()
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
            "expires_at", "<", now
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
        email: str,
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
            "email": email.lower(),
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
            "user_id", "==", user_id
        ).order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()

        return [doc.to_dict() for doc in docs]


# Module-level client instance
_firestore_client: Optional[FirestoreClient] = None


def get_firestore_client() -> FirestoreClient:
    """Get or create the Firestore client instance.

    Returns:
        FirestoreClient: Firestore client instance.
    """
    global _firestore_client
    
    if _firestore_client is None:
        _firestore_client = FirestoreClient()
    
    return _firestore_client
