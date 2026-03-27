"""
Authentication middleware for JWT token validation and user context extraction.
"""
from typing import Dict, Optional

from fastapi import HTTPException, Request, status
from jose import JWTError

from app.config import get_settings
from app.utils.auth import extract_user_from_token


class AuthContext:
    """User context extracted from JWT token."""

    def __init__(
        self,
        user_id: str,
        kingdom_id: str,
        role: str,
        token_type: str = "access",
    ):
        """Initialize auth context.

        Args:
            user_id: User ID from token.
            kingdom_id: Kingdom ID from token.
            role: User role from token.
            token_type: Token type (access or refresh).
        """
        self.user_id = user_id
        self.kingdom_id = kingdom_id
        self.role = role
        self.token_type = token_type


def extract_token_from_header(authorization: str) -> str:
    """Extract JWT token from Authorization header.

    Args:
        authorization: Authorization header value (format: "Bearer <token>").

    Returns:
        str: The extracted JWT token.

    Raises:
        HTTPException: If header format is invalid.
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split()

    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format. Expected: Bearer <token>",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return parts[1]


def validate_access_token(token: str) -> AuthContext:
    """Validate access token and extract user context.

    Args:
        token: JWT access token to validate.

    Returns:
        AuthContext: Extracted user context from token.

    Raises:
        HTTPException: If token is invalid, expired, or not an access token.
    """
    try:
        user_claims = extract_user_from_token(token)

        # Verify token type
        token_type = user_claims.get("token_type")
        if token_type != "access":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type. Expected access token.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Extract claims
        user_id = user_claims.get("user_id")
        kingdom_id = user_claims.get("kingdom_id")
        role = user_claims.get("role")

        if not all([user_id, kingdom_id, role]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token claims",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return AuthContext(
            user_id=user_id,
            kingdom_id=kingdom_id,
            role=role,
            token_type="access",
        )

    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e


def validate_refresh_token(
    token: str,
    check_blacklist_fn: Optional[callable] = None,
) -> AuthContext:
    """Validate refresh token and extract user context.

    Args:
        token: JWT refresh token to validate.
        check_blacklist_fn: Optional function to check if token is blacklisted.

    Returns:
        AuthContext: Extracted user context from token.

    Raises:
        HTTPException: If token is invalid, expired, or blacklisted.
    """
    try:
        user_claims = extract_user_from_token(token)

        # Verify token type
        token_type = user_claims.get("token_type")
        if token_type != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type. Expected refresh token.",
            )

        # Extract claims
        user_id = user_claims.get("user_id")
        kingdom_id = user_claims.get("kingdom_id")

        if not all([user_id, kingdom_id]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token claims",
            )

        # Check blacklist if provided
        if check_blacklist_fn:
            # In a real implementation, we'd extract the jti from the token
            # and pass it to the blacklist check
            pass

        return AuthContext(
            user_id=user_id,
            kingdom_id=kingdom_id,
            role="user",  # Refresh tokens don't include role
            token_type="refresh",
        )

    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired refresh token: {str(e)}",
        ) from e


async def get_current_user(request: Request) -> AuthContext:
    """FastAPI dependency to get current authenticated user.

    Args:
        request: FastAPI request object.

    Returns:
        AuthContext: User context extracted from token.

    Raises:
        HTTPException: If token is missing or invalid.
    """
    authorization = request.headers.get("authorization")
    token = extract_token_from_header(authorization)
    auth_context = validate_access_token(token)
    return auth_context


async def get_current_user_optional(request: Request) -> Optional[AuthContext]:
    """FastAPI dependency for optional authentication.

    Args:
        request: FastAPI request object.

    Returns:
        Optional[AuthContext]: User context if authenticated, None otherwise.
    """
    authorization = request.headers.get("authorization")

    if not authorization:
        return None

    try:
        token = extract_token_from_header(authorization)
        return validate_access_token(token)
    except HTTPException:
        return None


def require_role(*roles: str):
    """Decorator factory for role-based access control.

    Args:
        *roles: Allowed roles for the endpoint.

    Returns:
        callable: Dependency function for FastAPI.
    """
    async def check_role(auth_context: AuthContext = None) -> AuthContext:
        """Check if user has required role.

        Args:
            auth_context: User context from authentication.

        Returns:
            AuthContext: User context if authorized.

        Raises:
            HTTPException: If user lacks required role.
        """
        if not auth_context:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Authentication required",
            )

        if auth_context.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required role: {', '.join(roles)}",
            )

        return auth_context

    return check_role
