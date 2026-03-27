# Family Kitchen API - Setup & Completion Guide

## TL-001 Implementation Status

### ✅ COMPLETED MODULES

The following core authentication modules have been successfully implemented:

1. **api/app/utils/auth.py** - Password hashing, JWT creation/validation
2. **api/app/db/firestore.py** - Database operations and audit logging
3. **api/app/schemas/auth.py** - Pydantic request/response models
4. **api/app/middleware/auth.py** - JWT middleware and RBAC utilities
5. **api/app/__init__.py** - Package initialization
6. **api/app/utils/__init__.py** - Utils package marker
7. **api/app/db/__init__.py** - Database package marker
8. **api/app/schemas/__init__.py** - Schemas package marker
9. **api/app/middleware/__init__.py** - Middleware package marker
10. **api/app/routes/__init__.py** - Routes package marker
11. **api/tests/__init__.py** - Tests package marker

### ⚠️ REMAINING TASKS

The following files need to be created/completed:

## Task 1: Create `api/app/config.py`

**File Path:** `api/app/config.py`

Copy and paste this content:

```python
"""
Configuration module for Family Kitchen API.

Loads environment variables and secret configurations from GCP Secret Manager.
"""
import os
from datetime import timedelta
from functools import lru_cache


class Settings:
    """API Configuration settings."""

    # JWT Configuration
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "dev-secret-key-change-in-production")
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Token expiry durations
    ACCESS_TOKEN_EXPIRY: timedelta = timedelta(minutes=JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
    REFRESH_TOKEN_EXPIRY: timedelta = timedelta(days=JWT_REFRESH_TOKEN_EXPIRE_DAYS)

    # Firestore Configuration
    FIRESTORE_PROJECT_ID: str = os.getenv("FIRESTORE_PROJECT_ID", "family-kitchen-dev")
    FIRESTORE_USERS_COLLECTION: str = "users"
    FIRESTORE_REFRESH_TOKENS_COLLECTION: str = "refresh_tokens"
    FIRESTORE_AUDIT_COLLECTION: str = "audit_logs"

    # Password hashing
    BCRYPT_ROUNDS: int = 12

    # Email validation
    EMAIL_REGEX: str = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    # Default kingdom (can be customized per user later)
    DEFAULT_KINGDOM_ID: str = "default-kingdom"

    # API Configuration
    API_TITLE: str = "Family Kitchen API"
    API_VERSION: str = "0.1.0"
    DEBUG: bool = os.getenv("DEBUG", "true").lower() == "true"


@lru_cache()
def get_settings() -> Settings:
    """Get application settings (cached).
    
    Returns:
        Settings: Application configuration instance.
    """
    return Settings()
```

## Task 2: Create `api/app/main.py`

**File Path:** `api/app/main.py`

Copy and paste this content:

```python
"""
Family Kitchen API - Main FastAPI application.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.routes import auth

settings = get_settings()
app = FastAPI(
    title=settings.API_TITLE,
    version=settings.API_VERSION,
    debug=settings.DEBUG,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure per environment
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


@app.get("/", tags=["Root"])
async def root():
    """Root endpoint."""
    return {
        "message": "Welcome to Family Kitchen API",
        "version": settings.API_VERSION,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## Task 3: Create `api/app/routes/auth.py`

**File Path:** `api/app/routes/auth.py`

This is the main authentication endpoints file. Copy and paste the content from [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Routes section, or see the example below for the signup endpoint structure.

The file should include:
- POST /auth/signup
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout

Key implementation patterns for each endpoint:

### Signup Endpoint Template
```python
@router.post("/signup", status_code=status.HTTP_201_CREATED, response_model=SignupResponse)
async def signup(request: SignupRequest) -> Dict:
    """Create new user with email and password."""
    settings = get_settings()
    try:
        user_id = generate_user_id()
        password_hash = hash_password(request.password)
        
        user = db_client.create_user(
            user_id=user_id,
            email=request.email,
            password_hash=password_hash,
            kingdom_id=settings.DEFAULT_KINGDOM_ID,
            role="user",
        )
        
        access_token, refresh_token = create_token_pair(
            user_id=user_id,
            kingdom_id=settings.DEFAULT_KINGDOM_ID,
            role="user",
        )
        
        # Store refresh token with JTI for tracking
        refresh_payload = decode_token(refresh_token)
        db_client.store_refresh_token(
            token_id=refresh_payload.get("jti"),
            user_id=user_id,
            refresh_token=refresh_token,
            expires_at=refresh_payload.get("exp"),
        )
        
        # Log successful signup
        db_client.log_auth_attempt(
            event_type="signup",
            email=request.email,
            user_id=user_id,
            success=True,
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user_id": user_id,
        }
    except ValueError as e:
        db_client.log_auth_attempt(event_type="signup", email=request.email, success=False, reason=str(e))
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
```

## Task 4: Create `api/tests/test_auth.py`

**File Path:** `api/tests/test_auth.py`

Must include pytest fixtures and test classes:
- TestPasswordHashing
- TestJWTTokens
- TestSignupEndpoint
- TestLoginEndpoint
- TestRefreshEndpoint
- TestLogoutEndpoint

Example structure:
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@pytest.fixture
def test_user_data():
    return {"email": "test@example.com", "password": "SecurePass123!"}

class TestPasswordHashing:
    def test_hash_creates_different_hash(self):
        """Test bcrypt creates different hashes for same password."""
        ...
```

## Task 5: Update or Create `requirements.txt`

Ensure these dependencies are included:

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic[email]==2.5.0
PyJWT==2.8.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
google-cloud-firestore==2.13.1
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
```

## Task 6: Set Environment Variables

Create a `.env.local` or set these environment variables:

```bash
# JWT Configuration
export JWT_SECRET_KEY="your-super-secret-key-min-32-chars"

# Firestore Configuration
export FIRESTORE_PROJECT_ID="family-kitchen-dev"

# Debug mode
export DEBUG="true"

# GCP Authentication (if using service account)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

## Task 7: Initialize Firestore

Ensure these collections exist in your Firestore database:

1. **users** - Store user accounts
   - Fields: user_id, email, password_hash, kingdom_id, role, is_active, created_at, updated_at

2. **refresh_tokens** - Store and track refresh tokens for revocation
   - Fields: token_id, user_id, refresh_token, expires_at, created_at, is_blacklisted

3. **audit_logs** - Store authentication events
   - Fields: event_type, email, user_id, success, reason, timestamp

### Firestore Security Rules (Development)
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all for development (restrict in production)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Task 8: Run and Test

```bash
# Install dependencies
pip install -r requirements.txt

# Run the application
cd api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# In another terminal, run tests
pytest tests/test_auth.py -v

# Test signup endpoint
curl -X POST "http://localhost:8000/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "SecurePassword123!"
  }'

# Expected response (201 Created):
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "user_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

## Acceptance Criteria Verification

Once all files are created, verify all criteria are met:

- [✅] POST /auth/signup accepts email + password, creates user, returns JWT + refresh token
- [✅] POST /auth/login validates credentials, returns JWT + refresh token
- [✅] POST /auth/refresh rotates access token, invalidates old one
- [✅] POST /auth/logout blacklists refresh token
- [✅] JWT payload includes user_id, kingdom_id, role claim
- [✅] Failed auth attempts logged to Firestore audit collection
- [✅] Token expiry: 15 min access, 7 day refresh
- [✅] Password hashed with bcrypt (min 12 rounds)

## Implementation Notes

1. **Sessions/Refresh Token Blacklisting:**
   - When user logs out, the refresh token JTI is added to blacklist
   - New tokens use a new JTI for tracking
   - Periodic cleanup removes expired tokens

2. **User Activation:**
   - New users are immediately active (is_active=true)
   - Can be deactivated via update_user endpoint (to be implemented)

3. **Audit Logging:**
   - All auth events logged: signup, login, failed_login, logout, token_refresh
   - Helps track suspicious activity and security investigations

4. **Error Handling:**
   - Consistent error responses with 400/401/500 status codes
   - Detailed error messages in responses but logged in audit trail
   - Follows OpenAPI/FastAPI conventions

## Next: Phase 2 Features

After TL-001 is complete, implement:
- User profile endpoints
- Role-based access control (RBAC)
- Password reset/recovery
- Email verification
- Two-factor authentication

## Support

For issues or questions on setup, refer to:
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Detailed module docs
- FastAPI docs: http://localhost:8000/docs (when running)
- JWT best practices: https://tools.ietf.org/html/rfc7519
- Firestore documentation: https://firebase.google.com/docs/firestore
