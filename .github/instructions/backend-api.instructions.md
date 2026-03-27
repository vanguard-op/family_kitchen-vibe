---
description: "Use when developing backend API features for family_kitchen. Covers FastAPI patterns, Firestore integration, authentication, and family_kitchen-specific domain logic."
name: "Backend API - family_kitchen"
applyTo: "api/**"
---

# Backend API Development for family_kitchen

## Project Context

- **Framework**: FastAPI (Python)
- **Database**: Google Cloud Firestore (NoSQL)
- **Authentication**: OAuth2 + JWT
- **API Location**: `api/app/routes/`
- **Project Phases**: Phase 1 (Core), Phase 2 (Extended), Phase 3 (Nice-to-have)

## Core Domain Models

- **Kingdom**: Family unit/household management
- **User**: Family members with role-based profiles
- **Inventory**: Pantry/food items with expiration tracking
- **Allergies**: Member allergy profiles and restrictions
- **Chef Mode**: Shared cooking mode for collaborative meal prep

## Issue Prefix

When creating GitHub issues for backend API work, use **`API-`** prefix (e.g., `API-001: Implement inventory CRUD endpoints`).

## Implementation Priorities

### Phase 1 (Core)
- User authentication and kingdom setup
- Inventory CRUD with expiration alerts
- Allergy vault and restriction checking
- Basic role-based access control (RBAC)

### Phase 2 (Extended)
- Advanced inventory features (categories, tags, recipes)
- Notification system for expiring items
- Sharing and collaboration features

### Phase 3 (Nice-to-have)
- AI recipe suggestions
- Advanced reporting and analytics
- Third-party integrations

## Code Patterns

- **Models**: Pydantic schemas in `api/app/schemas/`
- **Routes**: FastAPI routes in `api/app/routes/`
- **Database**: Firestore adapters in `api/app/db/firestore.py`
- **Auth**: JWT middleware in `api/app/middleware/auth.py`
- **Tests**: Unit/integration tests in `api/tests/`

## Security Requirements

- All endpoints require JWT authentication (Bearer token)
- RBAC checks: owner, member, admin roles per kingdom
- Input validation on all requests
- Audit logging for sensitive operations (inventory changes, allergy updates)

## Testing

- Unit tests for business logic (`api/tests/test_*.py`)
- Integration tests for Firestore operations
- Auth/permission tests for RBAC enforcement
- Minimum 80% code coverage for routes

## Git Workflow

1. **Local development**: Make changes in `api/` and commit to local git
2. **Verify**: Run `git status` to confirm clean working directory
3. **Remote sync**: After verification, push to remote branch and create PR
4. **Keep in sync**: Local and remote must always be in sync
