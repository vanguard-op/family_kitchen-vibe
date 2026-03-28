from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
import logging

from app.db.firestore import (
    create_user,
    get_user_by_email,
    create_refresh_token_record,
    revoke_refresh_token,
    get_refresh_token_record,
)
from app.utils.auth import hash_password, verify_password, decode_token
from app.security.oauth2 import create_token_set
from app.audit import log_auth_attempt

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["auth"])


# Response Models
class TokenResponse(BaseModel):
    """Token response with access, ID, and refresh tokens"""
    access_token: str
    id_token: str
    refresh_token: str
    token_type: str = "Bearer"


class SignupResponse(TokenResponse):
    """Signup response"""
    pass


class LoginResponse(TokenResponse):
    """Login response"""
    pass


# Request Models
class SignupRequest(BaseModel):
    """Signup request model"""
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    """Login request model"""
    email: EmailStr
    password: str


class RefreshRequest(BaseModel):
    """Refresh token request model"""
    refresh_token: str


@router.post("/signup", response_model=SignupResponse, status_code=status.HTTP_201_CREATED)
async def signup(request: SignupRequest) -> SignupResponse:
    """
    Register a new user with email and password.
    
    Returns 201 with tokens on success.
    Returns 409 if email already exists.
    Returns 400 for invalid password.
    Returns 500 for server errors.
    """
    try:
        # Check if user already exists
        existing_user = await get_user_by_email(request.email)
        if existing_user:
            await log_auth_attempt(
                email=request.email,
                action="signup",
                success=False,
                reason="email_already_exists"
            )
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered"
            )
        
        # Hash and validate password
        try:
            hashed_password = hash_password(request.password)
        except ValueError as e:
            await log_auth_attempt(
                email=request.email,
                action="signup",
                success=False,
                reason="invalid_password"
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        
        # Create user
        user_id = await create_user(
            email=request.email,
            hashed_password=hashed_password
        )
        
        # Generate tokens (create_token_set is not async)
        access_token, id_token, refresh_token = create_token_set(
            user_id=user_id,
            email=request.email,
            kingdom_id="default-kingdom",
            role="user",
        )
        
        # Store refresh token record
        await create_refresh_token_record(user_id, refresh_token)
        
        # Log success
        await log_auth_attempt(
            email=request.email,
            action="signup",
            success=True,
            user_id=user_id
        )
        
        return SignupResponse(
            access_token=access_token,
            id_token=id_token,
            refresh_token=refresh_token,
            token_type="Bearer"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Signup error: {str(e)}", exc_info=True)
        await log_auth_attempt(
            email=request.email,
            action="signup",
            success=False,
            reason="server_error"
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during signup"
        )


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest) -> LoginResponse:
    """
    Authenticate user with email and password.
    
    Returns 200 with tokens on success.
    Returns 401 for invalid credentials or inactive user.
    Returns 500 for server errors.
    """
    try:
        # Get user by email
        user = await get_user_by_email(request.email)
        if not user:
            await log_auth_attempt(
                email=request.email,
                action="login",
                success=False,
                reason="user_not_found"
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Check if user is active
        if not user.get("is_active", False):
            await log_auth_attempt(
                email=request.email,
                action="login",
                success=False,
                reason="user_inactive",
                user_id=user.get("id")
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is inactive"
            )
        
        # Verify password
        try:
            if not verify_password(request.password, user.get("hashed_password", "")):
                await log_auth_attempt(
                    email=request.email,
                    action="login",
                    success=False,
                    reason="invalid_password",
                    user_id=user.get("id")
                )
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid email or password"
                )
        except ValueError as e:
            await log_auth_attempt(
                email=request.email,
                action="login",
                success=False,
                reason="password_verification_error",
                user_id=user.get("id")
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        
        # Generate tokens
        user_id = user.get("id")
        access_token, id_token, refresh_token = await create_token_set(user_id)
        
        # Store refresh token record
        await create_refresh_token_record(user_id, refresh_token)
        
        # Log success
        await log_auth_attempt(
            email=request.email,
            action="login",
            success=True,
            user_id=user_id
        )
        
        return LoginResponse(
            access_token=access_token,
            id_token=id_token,
            refresh_token=refresh_token,
            token_type="Bearer"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {str(e)}", exc_info=True)
        await log_auth_attempt(
            email=request.email,
            action="login",
            success=False,
            reason="server_error"
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during login"
        )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(request: RefreshRequest) -> TokenResponse:
    """
    Refresh authentication tokens using a valid refresh token.
    
    Returns 200 with new tokens on success.
    Returns 401 for invalid or revoked refresh token.
    Returns 500 for server errors.
    """
    try:
        # Decode refresh token
        try:
            payload = await decode_token(request.refresh_token, token_type="refresh")
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token"
            )
        
        user_id = payload.get("sub")
        
        # Check if token is revoked
        token_record = await get_refresh_token_record(user_id, request.refresh_token)
        if not token_record or token_record.get("revoked", False):
            await log_auth_attempt(
                action="refresh",
                success=False,
                reason="token_revoked",
                user_id=user_id
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token is invalid or revoked"
            )
        
        # Revoke old token
        await revoke_refresh_token(user_id, request.refresh_token)
        
        # Create new token set
        access_token, id_token, new_refresh_token = await create_token_set(user_id)
        
        # Store new refresh token record
        await create_refresh_token_record(user_id, new_refresh_token)
        
        # Log success
        await log_auth_attempt(
            action="refresh",
            success=True,
            user_id=user_id
        )
        
        return TokenResponse(
            access_token=access_token,
            id_token=id_token,
            refresh_token=new_refresh_token,
            token_type="Bearer"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Refresh token error: {str(e)}", exc_info=True)
        await log_auth_attempt(
            action="refresh",
            success=False,
            reason="server_error"
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during token refresh"
        )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(request: RefreshRequest) -> None:
    """
    Logout user by revoking their refresh token.
    
    Always returns 204 No Content (idempotent).
    Does not raise errors even if token is invalid or already revoked.
    """
    try:
        # Decode token to get user_id (best effort)
        try:
            payload = await decode_token(request.refresh_token, token_type="refresh")
            user_id = payload.get("sub")
            
            # Revoke the token (best effort, idempotent)
            await revoke_refresh_token(user_id, request.refresh_token)
            
            # Log success
            await log_auth_attempt(
                action="logout",
                success=True,
                user_id=user_id
            )
        except ValueError:
            # Invalid token, but still return 204 (idempotent)
            logger.debug("Logout attempt with invalid token")
            await log_auth_attempt(
                action="logout",
                success=False,
                reason="invalid_token"
            )
    
    except Exception as e:
        # Log error but still return 204 (idempotent)
        logger.error(f"Logout error: {str(e)}", exc_info=True)
        await log_auth_attempt(
            action="logout",
            success=False,
            reason="server_error"
        )
    
    # Always return 204 No Content
    return None
