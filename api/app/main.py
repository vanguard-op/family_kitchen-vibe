"""FastAPI application entry point"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.routes import auth, kingdom, inventory, allergies
from app.config import settings
from app.db.firestore import init_firestore


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager"""
    # Startup
    print("Starting Family Kitchen API...")
    init_firestore()
    print("✅ Firestore initialized")
    yield
    # Shutdown
    print("Shutting down Family Kitchen API...")


app = FastAPI(
    title=settings.API_TITLE,
    description="Kitchen management platform for solo/family households - The Royal Hearth",
    version=settings.API_VERSION,
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(kingdom.router, prefix="/kingdom", tags=["kingdom"])
app.include_router(inventory.router, prefix="/kingdom", tags=["inventory"])
app.include_router(allergies.router, prefix="/member", tags=["allergies"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to Family Kitchen API",
        "version": settings.API_VERSION,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy", "version": settings.API_VERSION}
