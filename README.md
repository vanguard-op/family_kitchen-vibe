# Family Kitchen (The Royal Hearth)

A mobile-first kitchen management system combining inventory, meal planning, and decision workflows under a playful "Kingdom" metaphor.

## Quick Start

### Prerequisites
- Python 3.11+
- Flutter SDK 3.10+
- Terraform 1.5+
- GCP Project with billing enabled

### Backend (FastAPI)

```bash
cd api
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API starts at `http://localhost:8000`. OpenAPI docs at `http://localhost:8000/docs`.

### Mobile (Flutter)

```bash
cd mobile_app
flutter pub get
flutter run
```

### Infrastructure (Terraform)

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## Project Structure

```
family_kitchen/
├── api/                    # FastAPI backend
├── mobile_app/             # Flutter mobile app
├── infra/                  # Terraform IaC for GCP
├── docs/                   # Documentation
├── .github/workflows/      # CI/CD pipelines
└── docker-compose.yml      # Local development stack
```

## Phase 1 Roadmap

- [x] GitHub Issues created (TL-001 to TL-009)
- [ ] Auth & User Foundation (TL-001)
- [ ] Kingdom Creation (TL-002)
- [ ] Role Management (TL-003)
- [ ] Allergy Vault (TL-004)
- [ ] Inventory CRUD (TL-005)
- [ ] Chef Mode UI (TL-006)
- [ ] Home Dashboard (TL-007)
- [ ] Data Layer & Cloud (TL-008)
- [ ] Sync & Offline (TL-009)

## Documentation

See [docs/](docs/) for:
- [Product Requirements](docs/prd.md)
- [Architecture](docs/architecture.md)
- [API Specification](docs/api-spec.md)
- [Database Schema](docs/database-schema.md)
- [Deployment Guide](docs/deployment.md)

## Stack

- **Backend:** FastAPI, Pydantic, Firestore
- **Mobile:** Flutter, Dart, SQLite
- **Infrastructure:** GCP (Cloud Run, Firestore, Secret Manager), Terraform
- **Auth:** OAuth2 + JWT
- **Notifications:** Firebase Cloud Messaging (FCM)

## Team

- 2 Backend Engineers
- 2 Mobile Engineers  
- 1 Cloud Engineer
- 1 QA Engineer
- 1 Product Owner / Tech Lead

## License

TBD
