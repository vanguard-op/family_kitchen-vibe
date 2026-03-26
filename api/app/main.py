"""FastAPI application entry point"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, kingdom, inventory, allergies
from app.config import settings

app = FastAPI(
    title="Family Kitchen API",
    description="Kitchen management platform for solo/family households",
    version="0.1.0",
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
    return {"message": "Welcome to Family Kitchen API", "version": "0.1.0"}


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}
