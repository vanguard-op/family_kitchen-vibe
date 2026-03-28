"""
Password hashing and validation utilities.

Note: Token generation has been moved to app/security/oauth2.py
"""
from passlib.context import CryptContext
import uuid

# Initialize password context for bcrypt hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Bcrypt has a maximum password length of 72 bytes
MAX_PASSWORD_LENGTH = 72


def validate_password(password: str) -> None:
    """Validate password meets requirements.
    
    Args:
        password: Password to validate
        
    Raises:
        ValueError: If password doesn't meet requirements
    """
    if not password:
        raise ValueError("Password cannot be empty")
    
    if len(password) < 8:
        raise ValueError("Password must be at least 8 characters")
    
    if len(password) > MAX_PASSWORD_LENGTH:
        raise ValueError(
            f"Password must not exceed {MAX_PASSWORD_LENGTH} characters "
            "(bcrypt limitation)"
        )


def hash_password(password: str) -> str:
    """Hash a plain text password using bcrypt with configured rounds.

    Args:
        password: Plain text password to hash.
        
    Returns:
        str: Hashed password suitable for storage.
        
    Raises:
        ValueError: If password validation fails
    """
    validate_password(password)
    
    try:
        return pwd_context.hash(password)
    except ValueError as e:
        # Handle bcrypt-specific errors
        if "password cannot be longer than 72 bytes" in str(e):
            raise ValueError(
                f"Password must not exceed {MAX_PASSWORD_LENGTH} characters"
            )
        raise ValueError(f"Password hashing failed: {str(e)}")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain text password against a hashed password.

    Args:
        plain_password: Plain text password to verify.
        hashed_password: Hashed password to compare against.

    Returns:
        bool: True if password matches, False otherwise.
    """
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except (ValueError, TypeError):
        # Handle invalid hash format or other verification errors
        return False

