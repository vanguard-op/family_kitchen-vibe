---
description: "Use when developing Flutter mobile features for family_kitchen. Covers provider state management, API integration, local storage, and family_kitchen feature screens."
name: "Mobile App - family_kitchen"
applyTo: "mobile_app/**"
---

# Mobile App Development for family_kitchen

## Project Context

- **Framework**: Flutter (Dart)
- **State Management**: Provider pattern
- **Local Storage**: SQLite via `database.dart`
- **API Client**: `services/api_client.dart` (FastAPI backend)
- **Sync**: `services/sync_manager.dart` for online/offline sync
- **App Location**: `mobile_app/lib/`
- **Project Phases**: Phase 1 (Core), Phase 2 (Extended), Phase 3 (Nice-to-have)

## Core Features & Screens

- **Splash Screen**: App initialization and auth check
- **Login/Signup**: Authentication flow
- **Kingdom Setup**: Family unit creation and invites
- **Member Management**: Add/remove family members
- **Inventory Screen**: List items, view expiration
- **Inventory Add**: Create new items with details
- **Allergy Setup**: Configure member allergies
- **Home Screen**: Dashboard and quick access
- **Chef Mode**: Collaborative cooking mode (Phase 2+)

## Issue Prefix

When creating GitHub issues for mobile work, use **`MOB-`** prefix (e.g., `MOB-001: Implement login screen with OAuth2`).

## Implementation Priorities

### Phase 1 (Core)
- Splash and auth screens (login, signup)
- Kingdom setup screen
- Member management screen
- Inventory list and add screens
- Allergy setup screen
- Basic home dashboard

### Phase 2 (Extended)
- Chef Mode collaborative features
- Advanced filtering/search
- Item categories and tags
- Push notifications for expiring items

### Phase 3 (Nice-to-have)
- Offline recipe suggestions
- Shopping list generation
- Social sharing features

## Code Patterns

- **Models**: Data models in `mobile_app/lib/models/` (e.g., `kingdom_model.dart`, `user_model.dart`)
- **Screens**: UI screens in `mobile_app/lib/screens/`
- **Providers**: State management in `mobile_app/lib/providers/` (auth, inventory providers)
- **Services**: API client and sync in `mobile_app/lib/services/`
- **Widgets**: Reusable widgets in `mobile_app/lib/widgets/` (input fields, buttons, loaders)
- **Utils**: Constants and validators in `mobile_app/lib/utils/`
- **Config**: Routes defined in `mobile_app/lib/config/routes.dart`

## Security & Data Handling

- **Auth**: JWT tokens stored securely (use secure storage plugin)
- **Offline sync**: Queue changes locally, sync when online
- **Local storage**: SQLite for sensitive data (encrypted if available)
- **API calls**: Use auth_provider to inject bearer token in headers
- **Allergy data**: Always validate server-side; sync before displaying restricted items

## Testing

- Widget tests for screens and UI logic
- Unit tests for providers and state management
- Integration tests for API client and sync behavior
- Mock API responses for offline testing

## Git Workflow

1. **Local development**: Make changes in `mobile_app/` and commit to local git
2. **Verify**: Run `git status` to confirm clean working directory
3. **Remote sync**: After verification, push to remote branch and create PR
4. **Keep in sync**: Local and remote must always be in sync
