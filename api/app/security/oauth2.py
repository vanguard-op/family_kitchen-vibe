"""OAuth2 and JWT token management using authlib."""
from datetime import datetime, timedelta, timezone
from typing import Dict, Optional, Tuple
import uuid

from authlib.jose import jwt, JWTError

from app.config import get_settings


def create_access_token(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT access token using authlib."""
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    payload = {
        "sub": user_id,
        "user_id": user_id,
        "kingdom_id": kingdom_id,
        "role": role,
        "scope": f"user:read user:write kingdom:{kingdom_id}",
        "exp": expire,
        "iat": now,
        "type": "access",
        "aud": "family-kitchen-api",
        "iss": "family-kitchen",
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
    """Create a JWT refresh token using authlib."""
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    payload = {
        "sub": user_id,
        "user_id": user_id,
        "kingdom_id": kingdom_id,
        "exp": expire,
        "iat": now,
        "type": "refresh",
        "aud": "family-kitchen-api",
        "iss": "family-kitchen",
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token if isinstance(token, str) else token.decode()


def create_token_pair(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
) -> Tuple[str, str]:
    """Create both access and refresh tokens."""
    access_token = create_access_token(user_id, kingdom_id, role)
    refresh_token = create_refresh_token(user_id, kingdom_id)
    return access_token, refresh_token


def decode_token(token: str) -> Dict:
    """Decode and validate a JWT token."""
    settings = get_settings()
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
            options={
                "verify_exp": True,
            },
        )
        return dict(payload)
    except JWTError as e:
        raise JWTError(f"Invalid token: {str(e)}")


def extract_user_from_token(token: str) -> Dict:
    """Extract user information from a valid token."""
    payload = decode_token(token)
    
    return {
        "user_id": payload.get("user_id") or payload.get("sub"),
        "kingdom_id": payload.get("kingdom_id"),
        "role": payload.get("role"),
        "token_type": payload.get("type"),
        "scope": payload.get("scope"),
    }


def generate_user_id() -> str:
    """Generate a unique user ID."""
    return str(uuid.uuid4())
