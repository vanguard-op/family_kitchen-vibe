"""
Authentication utilities for token and password management.
"""
from datetime import datetime, timedelta, timezone
from typing import Dict, Optional, Tuple
import uuid

from jose import jwt, JWTError
from jose.exceptions import ExpiredSignatureError
from passlib.context import CryptContext

from app.config import get_settings

# Initialize password context for bcrypt hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Hash a plain text password using bcrypt with configured rounds.
    
    Args:
        password: Plain text password to hash.
        
    Returns:
        str: Hashed password suitable for storage.
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain text password against a hashed password.
    
    Args:
        plain_password: Plain text password to verify.
        hashed_password: Hashed password to compare against.
        
    Returns:
        bool: True if password matches, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT access token with user claims.
    
    Args:
        user_id: Unique user identifier.
        kingdom_id: Kingdom/organization identifier.
        role: User role for RBAC.
        expires_delta: Optional custom expiration time. Uses config default if not provided.
        
    Returns:
        str: Encoded JWT access token.
    """
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    # Calculate expiration time in UTC
    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    payload = {
        "user_id": user_id,
        "kingdom_id": kingdom_id,
        "role": role,
        "exp": expire,
        "iat": now,
        "type": "access",
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token


def create_refresh_token(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT refresh token for token rotation.
    
    Args:
        user_id: Unique user identifier.
        kingdom_id: Kingdom/organization identifier.
        expires_delta: Optional custom expiration time. Uses config default if not provided.
        
    Returns:
        str: Encoded JWT refresh token.
    """
    settings = get_settings()
    
    if expires_delta is None:
        expires_delta = timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    # Calculate expiration time in UTC
    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    
    # Add a token ID for tracking in blacklist
    token_id = str(uuid.uuid4())
    
    payload = {
        "user_id": user_id,
        "kingdom_id": kingdom_id,
        "jti": token_id,  # JWT ID for blacklisting
        "exp": expire,
        "iat": now,
        "type": "refresh",
    }
    
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    
    return token


def create_token_pair(
    user_id: str,
    kingdom_id: str = "default-kingdom",
    role: str = "user",
) -> Tuple[str, str]:
    """Create both access and refresh tokens for a user.
    
    Args:
        user_id: Unique user identifier.
        kingdom_id: Kingdom/organization identifier.
        role: User role for RBAC.
        
    Returns:
        Tuple[str, str]: (access_token, refresh_token) pair.
    """
    access_token = create_access_token(user_id, kingdom_id, role)
    refresh_token = create_refresh_token(user_id, kingdom_id)
    
    return access_token, refresh_token


def decode_token(token: str) -> Dict:
    """Decode and verify a JWT token.
    
    Args:
        token: JWT token to decode.
        
    Returns:
        Dict: Decoded token payload.
        
    Raises:
        jwt.InvalidTokenError: If token is invalid, expired, or cannot be decoded.
    """
    settings = get_settings()
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        return payload
    except ExpiredSignatureError as e:
        raise JWTError("Token has expired") from e
    except JWTError as e:
        raise JWTError(f"Invalid token: {str(e)}") from e


def extract_user_from_token(token: str) -> Dict:
    """Extract user information from a valid token.
    
    Args:
        token: JWT token to extract claims from.
        
    Returns:
        Dict: User claims including user_id, kingdom_id, role.
        
    Raises:
        jwt.InvalidTokenError: If token is invalid or expired.
    """
    payload = decode_token(token)
    
    return {
        "user_id": payload.get("user_id"),
        "kingdom_id": payload.get("kingdom_id"),
        "role": payload.get("role"),
        "token_type": payload.get("type"),
    }


def generate_user_id() -> str:
    """Generate a unique user ID.
    
    Returns:
        str: UUID4 formatted user ID.
    """
    return str(uuid.uuid4())
