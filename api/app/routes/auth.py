"""Authentication endpoints"""
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.auth import (
    SignupRequest,
    LoginRequest,
    RefreshTokenRequest,
    TokenResponse,
    ErrorResponse,
)
from app.db.firestore import (
    create_user,
    get_user_by_email,
    create_refresh_token_record,
    get_refresh_token_record,
    revoke_refresh_token,
    log_auth_attempt,
)
from app.utils.auth import (
    hash_password,
    verify_password,
    create_token_pair,
    decode_token,
)
from app.config import settings
from datetime import datetime

router = APIRouter()


@router.post(
    "/signup",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    responses={400: {"model": ErrorResponse}, 409: {"model": ErrorResponse}},
)
async def signup(request: SignupRequest):
    """
    Sign up a new user account.

    Args:
        request: Signup request with email and password

    Returns:
        TokenResponse with access_token, refresh_token, and user_id

    Raises:
        HTTPException: If email already registered (409) or validation fails (400)
    """
    try:
        # Check if user already exists
        existing_user = await get_user_by_email(request.email)
        if existing_user:
            await log_auth_attempt(
                event_type="signup_failed",
                email=request.email,
                reason="email_already_exists",
            )
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        # Hash password
        password_hash = hash_password(request.password)

        # Create user in Firestore
        user_id = await create_user(
            email=request.email,
            password_hash=password_hash,
        )

        # Create token pair
        access_token, refresh_token = create_token_pair(
            user_id=user_id,
            email=request.email,
            role="User",
        )

        # Store refresh token in Firestore
        await create_refresh_token_record(
            user_id=user_id,
            refresh_token=refresh_token,
        )

        # Log successful signup
        await log_auth_attempt(
            event_type="signup_success",
            email=request.email,
            user_id=user_id,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user_id=user_id,
        )

    except HTTPException:
        raise
    except Exception as e:
        await log_auth_attempt(
            event_type="signup_error",
            email=request.email,
            reason=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Signup failed",
        )


@router.post(
    "/login",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    responses={401: {"model": ErrorResponse}},
)
async def login(request: LoginRequest):
    """
    Authenticate user and return access/refresh tokens.

    Args:
        request: Login request with email and password

    Returns:
        TokenResponse with access_token and refresh_token

    Raises:
        HTTPException: If credentials invalid (401)
    """
    try:
        # Get user from Firestore
        user = await get_user_by_email(request.email)
        if not user:
            await log_auth_attempt(
                event_type="login_failed",
                email=request.email,
                reason="user_not_found",
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        # Verify password
        if not verify_password(request.password, user["password_hash"]):
            await log_auth_attempt(
                event_type="login_failed",
                email=request.email,
                reason="invalid_password",
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        # Check if user is active
        if user.get("deactivated_at"):
            await log_auth_attempt(
                event_type="login_failed",
                email=request.email,
                reason="user_deactivated",
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account has been deactivated",
            )

        # Create token pair
        user_id = user["user_id"]
        access_token, refresh_token = create_token_pair(
            user_id=user_id,
            email=request.email,
            role=user.get("role", "User"),
        )

        # Store refresh token
        await create_refresh_token_record(
            user_id=user_id,
            refresh_token=refresh_token,
        )

        # Log successful login
        await log_auth_attempt(
            event_type="login_success",
            email=request.email,
            user_id=user_id,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
        )

    except HTTPException:
        raise
    except Exception as e:
        await log_auth_attempt(
            event_type="login_error",
            email=request.email,
            reason=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Login failed",
        )


@router.post(
    "/refresh",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    responses={401: {"model": ErrorResponse}},
)
async def refresh(request: RefreshTokenRequest):
    """
    Refresh access token using refresh token.

    Args:
        request: Refresh token request

    Returns:
        TokenResponse with new access_token

    Raises:
        HTTPException: If refresh token invalid (401)
    """
    try:
        # Decode refresh token
        claims = decode_token(request.refresh_token)
        user_id = claims.get("sub")
        token_type = claims.get("type")

        if token_type != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type",
            )

        # Verify refresh token in Firestore (not blacklisted)
        token_record = await get_refresh_token_record(user_id)
        if not token_record:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token invalid or revoked",
            )

        # Create new token pair
        access_token, new_refresh_token = create_token_pair(
            user_id=user_id,
            email=claims.get("email"),
            role=claims.get("role", "User"),
        )

        # Revoke old refresh token
        await revoke_refresh_token(user_id)

        # Store new refresh token
        await create_refresh_token_record(
            user_id=user_id,
            refresh_token=new_refresh_token,
        )

        await log_auth_attempt(
            event_type="token_refresh_success",
            user_id=user_id,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
        )

    except HTTPException:
        raise
    except Exception as e:
        await log_auth_attempt(
            event_type="token_refresh_failed",
            reason=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token refresh failed",
        )


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def logout(request: RefreshTokenRequest):
    """
    Logout user by revoking refresh token.

    Args:
        request: Refresh token to revoke
    """
    try:
        claims = decode_token(request.refresh_token)
        user_id = claims.get("sub")

        # Revoke refresh token
        await revoke_refresh_token(user_id)

        await log_auth_attempt(
            event_type="logout_success",
            user_id=user_id,
        )

        return None

    except Exception as e:
        await log_auth_attempt(
            event_type="logout_failed",
            reason=str(e),
        )
        # Don't raise error - logout always succeeds
        return None
