# Architecture Overview

## System Design

Family Kitchen uses a mobile-first architecture with a FastAPI backend and Flutter mobile frontend.

### High-Level Architecture

```
┌─────────────────┐
│   Flutter App   │
│   (iOS/Android) │
└────────┬────────┘
         │
      HTTPS
         │
┌────────▼────────────────────┐
│  FastAPI Backend            │
│  (Cloud Run)                │
├─────────────────────────────┤
│ • Auth/JWT                  │
│ • Kingdom/Member CRUD       │
│ • Inventory/Allergy API     │
│ • Dashboard aggregation     │
└────────┬────────────────────┘
         │
      APIs
         │
┌────────▼─────────────────────┐
│  Firestore (NoSQL)          │
│  ├─ users                   │
│  ├─ kingdoms                │
│  ├─ members                 │
│  ├─ inventory               │
│  ├─ allergies               │
│  └─ audit_logs              │
└─────────────────────────────┘
```

## Technology Stack

### Backend
- **Framework:** FastAPI (Python 3.11+)
- **Server:** Uvicorn (ASGI)
- **Database:** Firestore (NoSQL)
- **Auth:** OAuth2 + JWT
- **Validation:** Pydantic
- **Infrastructure:** GCP Cloud Run

### Mobile
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Local Storage:** SQLite (via sqflite)
- **Networking:** http + dio packages
- **Notifications:** Firebase Cloud Messaging (FCM)

### Infrastructure
- **Cloud:** Google Cloud Platform (GCP)
- **Compute:** Cloud Run (serverless)
- **Database:** Firestore (managed)
- **Secrets:** Secret Manager
- **Logging:** Cloud Logging
- **IaC:** Terraform

## Data Flow

### Authentication
1. User signs up/logs in via mobile app
2. FastAPI validates credentials and returns JWT + refresh token
3. Mobile app stores JWT securely (encrypted SharedPreferences/Keychain)
4. Subsequent API requests include JWT in Authorization header
5. FastAPI middleware validates JWT and extracts user/role claims

### Inventory Management
1. User adds inventory item (manual or barcode scan)
2. Mobile app sends to backend API
3. FastAPI validates and stores in Firestore
4. Backend checks expiry window and schedules FCM notification if needed
5. Mobile app periodically syncs with backend
6. Local cache updated on successful sync

### Multi-tenancy
- All resources partitioned by `kingdom_id`
- Firestore security rules enforce kingdom-scoped access
- JWT includes `kingdom_id` claim for RBAC checks

## Scalability Considerations

- **Partition by kingdom_id** for even distribution
- **Pagination** on inventory lists (50 items/page)
- **Caching** of dashboard data (60-second TTL)
- **Eventual consistency** for multi-member sync
- **Batch operations** for sync queue processing

## Security Model

- **Transport:** TLS/HTTPS mandatory
- **Auth:** OAuth2 password flow + JWT (15-min access, 7-day refresh)
- **Authorization:** Role-based RBAC on all endpoints
- **Encryption:** PII encrypted at rest (Tink library)
- **Audit Logging:** All role changes and auth failures logged
- **Secret Management:** GCP Secret Manager for JWT key

## Disaster Recovery

- **Firestore Backups:** Daily snapshots, 30-day retention
- **Terraform State:** Remote backend in GCS
- **Multi-region Firestore:** For resilience
