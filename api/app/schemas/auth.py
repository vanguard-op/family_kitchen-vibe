"""
Pydantic schemas for authentication endpoints.
"""
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class SignupRequest(BaseModel):
    """Request schema for user signup."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(
        ...,
        min_length=8,
        description="User password (minimum 8 characters)",
    )

    class Config:
        """Pydantic config."""
        example = {
            "email": "user@example.com",
            "password": "SecurePass123!",
        }


class LoginRequest(BaseModel):
    """Request schema for user login."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")

    class Config:
        """Pydantic config."""
        example = {
            "email": "user@example.com",
            "password": "SecurePass123!",
        }


class RefreshTokenRequest(BaseModel):
    """Request schema for token refresh."""

    refresh_token: str = Field(..., description="Refresh token")

    class Config:
        """Pydantic config."""
        example = {
            "refresh_token": "eyJ...",
        }


class LogoutRequest(BaseModel):
    """Request schema for user logout."""

    refresh_token: str = Field(..., description="Refresh token to invalidate")

    class Config:
        """Pydantic config."""
        example = {
            "refresh_token": "eyJ...",
        }


class TokenResponse(BaseModel):
    """Response schema for token endpoints."""

    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")

    class Config:
        """Pydantic config."""
        example = {
            "access_token": "eyJ...",
            "refresh_token": "eyJ...",
            "token_type": "bearer",
        }


class AuthorizedUser(BaseModel):
    """User metadata from authenticated response."""

    user_id: str = Field(..., description="Unique user ID")
    kingdom_id: str = Field(..., description="Kingdom/organization ID")
    email: str = Field(..., description="User email address")
    role: str = Field(..., description="User role")

    class Config:
        """Pydantic config."""
        example = {
            "user_id": "550e8400-e29b-41d4-a716-446655440000",
            "kingdom_id": "default-kingdom",
            "email": "user@example.com",
            "role": "user",
        }


class LoginResponse(TokenResponse):
    """Response schema for login endpoint with user metadata."""

    user_id: str = Field(..., description="Unique user ID")
    kingdom_id: str = Field(..., description="Kingdom/organization ID")
    email: str = Field(..., description="User email address")
    role: str = Field(..., description="User role")

    class Config:
        """Pydantic config."""
        example = {
            "access_token": "eyJ...",
            "refresh_token": "eyJ...",
            "token_type": "bearer",
            "user_id": "550e8400-e29b-41d4-a716-446655440000",
            "kingdom_id": "default-kingdom",
            "email": "user@example.com",
            "role": "user",
        }


class SignupResponse(LoginResponse):
    """Response schema for signup endpoint."""

    class Config:
        """Pydantic config."""
        example = {
            "access_token": "eyJ...",
            "refresh_token": "eyJ...",
            "token_type": "bearer",
            "user_id": "550e8400-e29b-41d4-a716-446655440000",
            "kingdom_id": "default-kingdom",
            "email": "user@example.com",
            "role": "user",
        }


class UserResponse(BaseModel):
    """Response schema for user information."""

    user_id: str = Field(..., description="Unique user ID")
    email: str = Field(..., description="User email")
    kingdom_id: str = Field(..., description="Kingdom ID")
    role: str = Field(..., description="User role")
    is_active: bool = Field(..., description="Whether user is active")
    created_at: str = Field(..., description="Account creation timestamp")

    class Config:
        """Pydantic config."""
        example = {
            "user_id": "550e8400-e29b-41d4-a716-446655440000",
            "email": "user@example.com",
            "kingdom_id": "default-kingdom",
            "role": "user",
            "is_active": True,
            "created_at": "2026-03-27T10:00:00Z",
        }


class ErrorResponse(BaseModel):
    """Response schema for error responses."""

    detail: str = Field(..., description="Error message")
    error_code: Optional[str] = Field(None, description="Error code")

    class Config:
        """Pydantic config."""
        example = {
            "detail": "Invalid credentials",
            "error_code": "INVALID_CREDENTIALS",
        }
