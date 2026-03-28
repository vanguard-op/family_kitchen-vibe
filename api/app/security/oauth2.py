"""OAuth2 OIDC and JWT token management using authlib.

Implements OpenID Connect (OIDC) on top of OAuth2 with three tokens:
- access_token: For API access with scope-based permissions
- id_token: For user identity (email, user_id, kingdom_id, role)
- refresh_token: For obtaining new token pairs
"""
from datetime import datetime, timedelta, timezone
from typing import Dict, Optional, Tuple
import uuid

from authlib.jose import jwt
from authlib.jose.errors import JoseError

from app.config import get_settings


# Role-to-scope mapping for RBAC
ROLE_SCOPE_MAP = {
    "King": "user:read user:write kingdom:admin kingdom:member:write inventory:manage allergies:manage",
    "Queen": "user:read user:write kingdom:admin kingdom:member:write inventory:manage allergies:manage",
    "Prince": "user:read user:write kingdom:member:read inventory:manage allergies:read",
    "Princess": "user:read user:write kingdom:member:read inventory:manage allergies:read",
    "Chef": "user:read inventory:read allergies:read",
    "Visitor": "user:read",
    "user": "user:read user:write kingdom:member:read inventory:manage allergies:read",
}


def get_scopes_for_role(role: str) -> str:
    """Get OAuth2 scopes for a given role.
    
    Args:
        role: User role (e.g., 'King', 'Chef', 'user')
        
    Returns:
        str: Space-separated scopes for the role
    """
    return ROLE_SCOPE_MAP.get(role, ROLE_SCOPE_MAP["user"])


def create_access_token(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT access token with scope-based permissions.
    
    Access token contains scopes derived from role, not user identity.
    
    Args:
        user_id: Unique user identifier.
        kingdom_id: Kingdom/organization identifier.
        role: User role for scope derivation.
        expires_delta: Optional custom expiration time.
        
    Returns:
        str: Encoded JWT access token.
    """
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    scopes = get_scopes_for_role(role)
    
    payload = {
        "sub": user_id,  # Subject (user_id)
        "aud": "family-kitchen-api",  # Audience
        "iss": "family-kitchen",  # Issuer
        "scope": scopes,  # OAuth2 scopes based on role
        "kingdom_id": kingdom_id,  # For kingdom-scoped permissions
        "exp": expire,
        "iat": now,
        "type": "access",
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token if isinstance(token, str) else token.decode()


def create_id_token(
    user_id: str,
    email: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create an OIDC ID token with user identity information.
    
    ID token contains user identity (email, user_id, kingdom_id, role).
    Mobile app decodes this to get user information.
    
    Args:
        user_id: Unique user identifier.
        email: User email address.
        kingdom_id: Kingdom/organization identifier.
        role: User role.
        expires_delta: Optional custom expiration time.
        
    Returns:
        str: Encoded JWT ID token.
    """
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    payload = {
        "sub": user_id,  # Subject (user_id)
        "aud": "family-kitchen-mobile",  # Audience (for mobile app)
        "iss": "family-kitchen",  # Issuer
        "email": email,  # User identity
        "user_id": user_id,
        "kingdom_id": kingdom_id,
        "role": role,
        "exp": expire,
        "iat": now,
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token if isinstance(token, str) else token.decode()


def create_refresh_token(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT refresh token.
    
    Refresh token is long-lived and used to obtain new access/id tokens.
    
    Args:
        user_id: Unique user identifier.
        kingdom_id: Kingdom/organization identifier.
        expires_delta: Optional custom expiration time.
        
    Returns:
        str: Encoded JWT refresh token.
    """
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    payload = {
        "sub": user_id,
        "aud": "family-kitchen-api",
        "iss": "family-kitchen",
        "kingdom_id": kingdom_id,
        "exp": expire,
        "iat": now,
        "type": "refresh",
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token if isinstance(token, str) else token.decode()


def create_token_set(
    user_id: str,
    email: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
) -> Tuple[str, str, str]:
    """Create a complete token set (access, id, refresh) for OIDC flow.
    
    Returns the three-token set used in OpenID Connect:
    - access_token: For API requests
    - id_token: For user identity (decoded by client)
    - refresh_token: For refreshing the set
    
    Args:
        user_id: Unique user identifier.
        email: User email address.
        kingdom_id: Kingdom/organization identifier.
        role: User role for scope derivation.
        
    Returns:
        Tuple[str, str, str]: (access_token, id_token, refresh_token)
    """
    access_token = create_access_token(user_id, kingdom_id, role)
    id_token = create_id_token(user_id, email, kingdom_id, role)
    refresh_token = create_refresh_token(user_id, kingdom_id)
    return access_token, id_token, refresh_token


def decode_token(token: str) -> Dict:
    """Decode and validate a JWT token."""
    settings = get_settings()
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        return dict(payload)
    except (JoseError, ValueError) as e:
        raise ValueError(f"Invalid token: {str(e)}")


def extract_user_from_token(token: str) -> Dict:
    """Extract user information from a valid token."""
    payload = decode_token(token)
    
    return {
        "user_id": payload.get("user_id") or payload.get("sub"),
        "kingdom_id": payload.get("kingdom_id"),
        "role": payload.get("role"),
        "email": payload.get("email"),
        "token_type": payload.get("type"),
        "scope": payload.get("scope"),
    }


def extract_user_from_id_token(id_token: str) -> Dict:
    """Extract user identity information from an ID token.
    
    ID tokens contain user identity (email, user_id, kingdom_id, role).
    
    Args:
        id_token: JWT ID token from login response
        
    Returns:
        Dict: User identity information {user_id, email, kingdom_id, role}
        
    Raises:
        ValueError: If token is invalid or expired
    """
    payload = decode_token(id_token)
    
    return {
        "user_id": payload.get("user_id") or payload.get("sub"),
        "email": payload.get("email"),
        "kingdom_id": payload.get("kingdom_id"),
        "role": payload.get("role"),
    }


def generate_user_id() -> str:
    """Generate a unique user ID."""
    return str(uuid.uuid4())
