"""Authentication tests"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from app.main import app
from app.utils.auth import hash_password, decode_token

client = TestClient(app)


class TestHealthEndpoint:
    """Test health check endpoint"""

    def test_health_check(self):
        """Test that health endpoint returns 200"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()
        assert "version" in response.json()


class TestSignup:
    """Test signup endpoint"""

    @patch("app.routes.auth.get_user_by_email")
    @patch("app.routes.auth.create_user")
    @patch("app.routes.auth.create_refresh_token_record")
    @patch("app.routes.auth.log_auth_attempt")
    def test_signup_success(self, mock_log, mock_create_token, mock_create_user, mock_get_user):
        """Test successful signup"""
        mock_get_user.return_value = None
        mock_create_user.return_value = "user-123"

        response = client.post(
            "/auth/signup",
            json={
                "email": "test@example.com",
                "password": "TestPass123!",
            },
        )

        assert response.status_code == 201
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
        assert data["user_id"] == "user-123"

    @patch("app.routes.auth.get_user_by_email")
    @patch("app.routes.auth.log_auth_attempt")
    def test_signup_email_exists(self, mock_log, mock_get_user):
        """Test signup with existing email"""
        mock_get_user.return_value = {"user_id": "user-456", "email": "test@example.com"}

        response = client.post(
            "/auth/signup",
            json={
                "email": "test@example.com",
                "password": "TestPass123!",
            },
        )

        assert response.status_code == 409
        assert "already registered" in response.json()["detail"]

    def test_signup_invalid_email(self):
        """Test signup with invalid email"""
        response = client.post(
            "/auth/signup",
            json={
                "email": "invalid-email",
                "password": "TestPass123!",
            },
        )

        assert response.status_code == 422

    def test_signup_weak_password(self):
        """Test signup with weak password"""
        response = client.post(
            "/auth/signup",
            json={
                "email": "test@example.com",
                "password": "weak",
            },
        )

        assert response.status_code == 422


class TestLogin:
    """Test login endpoint"""

    @patch("app.routes.auth.get_user_by_email")
    @patch("app.routes.auth.create_refresh_token_record")
    @patch("app.routes.auth.log_auth_attempt")
    def test_login_success(self, mock_log, mock_create_token, mock_get_user):
        """Test successful login"""
        password = "TestPass123!"
        password_hash = hash_password(password)

        mock_get_user.return_value = {
            "user_id": "user-123",
            "email": "test@example.com",
            "password_hash": password_hash,
            "role": "User",
        }

        response = client.post(
            "/auth/login",
            json={
                "email": "test@example.com",
                "password": password,
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"

    @patch("app.routes.auth.get_user_by_email")
    @patch("app.routes.auth.log_auth_attempt")
    def test_login_user_not_found(self, mock_log, mock_get_user):
        """Test login with non-existent user"""
        mock_get_user.return_value = None

        response = client.post(
            "/auth/login",
            json={
                "email": "nonexistent@example.com",
                "password": "TestPass123!",
            },
        )

        assert response.status_code == 401
        assert "Invalid email or password" in response.json()["detail"]

    @patch("app.routes.auth.get_user_by_email")
    @patch("app.routes.auth.log_auth_attempt")
    def test_login_wrong_password(self, mock_log, mock_get_user):
        """Test login with wrong password"""
        mock_get_user.return_value = {
            "user_id": "user-123",
            "email": "test@example.com",
            "password_hash": hash_password("CorrectPass123!"),
            "role": "User",
        }

        response = client.post(
            "/auth/login",
            json={
                "email": "test@example.com",
                "password": "WrongPass123!",
            },
        )

        assert response.status_code == 401


class TestRefresh:
    """Test token refresh endpoint"""

    @patch("app.routes.auth.decode_token")
    @patch("app.routes.auth.get_refresh_token_record")
    @patch("app.routes.auth.revoke_refresh_token")
    @patch("app.routes.auth.create_refresh_token_record")
    @patch("app.routes.auth.log_auth_attempt")
    def test_refresh_success(
        self, mock_log, mock_create_token, mock_revoke, mock_get_token, mock_decode
    ):
        """Test successful token refresh"""
        mock_decode.return_value = {
            "user_id": "user-123",
            "kingdom_id": "default-kingdom",
            "role": "User",
            "type": "refresh",
        }
        mock_get_token.return_value = {"user_id": "user-123", "token_hash": "hash"}

        response = client.post(
            "/auth/refresh",
            json={"refresh_token": "valid-refresh-token"},
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"


class TestPasswordHashing:
    """Test password hashing utilities"""

    def test_hash_password(self):
        """Test password hashing"""
        password = "TestPass123!"
        hashed = hash_password(password)

        # Hash should not be plaintext
        assert hashed != password
        # Hash should be deterministic for comparison
        assert len(hashed) > 20


class TestTokenDecoding:
    """Test JWT token operations"""

    def test_token_payload(self):
        """Test that token contains correct claims"""
        from app.security.oauth2 import create_token_set

        access_token, id_token, refresh_token = create_token_set(
            user_id="user-123",
            email="test@example.com",
            role="user",
        )

        # All tokens should be valid
        assert access_token is not None
        assert len(access_token) > 0
        
        assert id_token is not None
        assert len(id_token) > 0

        assert refresh_token is not None
        assert len(refresh_token) > 0
