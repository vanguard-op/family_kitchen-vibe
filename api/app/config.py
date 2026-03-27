"""Application configuration"""
from functools import lru_cache
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings"""

    # API
    API_TITLE: str = "Family Kitchen API"
    API_VERSION: str = "0.1.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:8000",
        "http://localhost:5000",
    ]

    # Auth
    JWT_SECRET_KEY: str = "change-me-in-production-use-secret-manager"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database
    FIRESTORE_PROJECT_ID: str = "family-kitchen-dev"
    FIRESTORE_CREDENTIALS_PATH: str = ""
    FIRESTORE_USERS_COLLECTION: str = "users"
    FIRESTORE_REFRESH_TOKENS_COLLECTION: str = "refresh_tokens"
    FIRESTORE_AUDIT_COLLECTION: str = "audit_logs"
    FIRESTORE_KINGDOMS_COLLECTION: str = "kingdoms"
    FIRESTORE_INVENTORY_COLLECTION: str = "inventory"
    FIRESTORE_ALLERGIES_COLLECTION: str = "allergies"

    # GCP
    GCP_PROJECT_ID: str = "family-kitchen-dev"
    GCP_REGION: str = "us-central1"

    # Security
    BCRYPT_ROUNDS: int = 12

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = Settings()
