---
description: "Use when technical lead planning and coordinating family_kitchen work. Covers phase breakdown, issue conventions, subagent delegation, and cross-team coordination for family_kitchen."
name: "Technical Lead Coordination - family_kitchen"
applyTo: "docs/prd.md"
---

# Technical Lead Coordination for family_kitchen

## Project Overview

**family_kitchen** is a collaborative family meal management platform with:
- **Kingdom**: Family/household unit management
- **Inventory**: Smart pantry tracking with expiration alerts
- **Allergies**: Health restriction profiling and enforcement
- **Chef Mode**: Shared real-time cooking collaboration
- **Auth**: Role-based access (owner, member, admin)

## Three-Phase Delivery Plan

### Phase 1: Core MVP (Weeks 1-4)
**Non-negotiable features for app launch**

**Backend (API)**:
- User authentication (signup, login, JWT)
- Kingdom creation and invite system
- Inventory CRUD with expiration tracking
- Allergy vault and restriction checking
- Basic RBAC enforcement

**Mobile (Flutter)**:
- Splash and auth screens
- Kingdom setup and member management
- Inventory list and add screens
- Allergy configuration
- Home dashboard

**Infrastructure**:
- GCP project setup
- Firestore database and security rules
- Cloud Run deployment
- IAM and Secret Manager
- Monitoring and logging

**Issue Prefix**: `API-`, `MOB-`, `INFRA-` (e.g., `API-001`)

### Phase 2: Extended Features (Weeks 5-8)
**Enhanced UX and data capabilities**

- Inventory categories, tags, and search
- Expiration alerts and notifications
- Sharing and collaborative features
- Chef Mode (initial MVP)
- Advanced RBAC (viewer, editor roles)

**Issue Prefix**: Append `_P2` to core identifiers (e.g., `API-001_P2`)

### Phase 3: Nice-to-Have (Weeks 9+)
**Polish, analytics, and integrations**

- AI recipe suggestions
- Advanced reporting and dashboards
- Third-party recipe API integration
- Export and backup features

**Issue Prefix**: Append `_P3` (e.g., `API-001_P3`)

## Issue Naming Convention

Use this structure for all GitHub issues:

```
[PREFIX]-[NUMBER]: [Action Verb] [Noun/Domain] [Context]

Examples:
- API-001: Implement user authentication with OAuth2 and JWT
- MOB-001: Build login screen with email/password flow
- INFRA-001: Provision GCP project and Firestore database
- TL-001: Decompose Phase 1 PRD into engineering tasks
```

### Prefix Meanings
- **API-**: Backend API development (FastAPI, Firestore, business logic)
- **MOB-**: Mobile app development (Flutter, state management, screens)
- **INFRA-**: Cloud infrastructure (Terraform, GCP, deployment)
- **TL-**: Technical lead coordination (planning, decomposition, cross-team)

## Subagent Delegation Pattern

When assigning work to specialized agents, use this structure:

```
Task: [Issue Title]
Agent: [Senior Backend Developer Agent | Senior Mobile Developer Agent | Senior Cloud Engineer Agent]
Context: [Phase, related issues, acceptance criteria]
Deliverables: [Code, tests, documentation]
```

### Example Delegation

**To Senior Backend Developer Agent**:
```
Task: API-001: Implement user authentication endpoints
Context: Phase 1 Core, Kingdom setup depends on this
Acceptance Criteria:
- POST /auth/signup and /auth/login endpoints
- JWT token generation and validation
- User model with kingdom association
- 80% test coverage
- RBAC check for kingdom access
```

**To Senior Mobile Developer Agent**:
```
Task: MOB-001: Build login screen
Context: Phase 1 Core, blocks all other screens
Acceptance Criteria:
- Email/password input fields (validators in utils)
- Login button with loading state
- Error handling and user feedback
- Widget tests for state transitions
- Integration with auth_provider
```

**To Senior Cloud Engineer Agent**:
```
Task: INFRA-001: Provision GCP and Firestore
Context: Phase 1 Core, blocks API deployment
Acceptance Criteria:
- GCP project with billing enabled
- Firestore database in us-central1
- Security rules enforcing kingdom-level access
- Service account with least privilege IAM
- Terraform up-to-date in main branch
```

## Cross-Team Dependencies

**Critical flow**:
1. `INFRA-001` → `API-001` → `MOB-001` → `MOB-002`
   - Infra must provision GCP/Firestore
   - API must implement auth endpoints
   - Mobile can't test login without live API

**Parallel tracks**:
- `INFRA-002` (Cloud Run, monitoring) and `API-002` (inventory endpoints) can run in parallel
- `MOB-002` (inventory screens) can start once `API-002` API contracts are defined

## Task Breakdown Checklist

When creating Phase 1 task list, ensure:

- [ ] All endpoints listed with HTTP method, path, auth requirement
- [ ] All data models mapped (Kingdom, User, inventory, Allergy)
- [ ] RBAC requirements explicit (who can create, read, update, delete)
- [ ] Security requirements called out (JWT, encryption, audit logging)
- [ ] Testing requirements specified (unit, integration, coverage targets)
- [ ] Database schema or Firestore collection structure defined
- [ ] Mobile screens mapped to backend endpoints
- [ ] Deployment checklist for Phase 1 go-live

## Status Tracking

Use GitHub issue links and pull requests to track progress:

1. Create issue for each user story (e.g., `API-001`)
2. Create subtasks or checklists in issue description
3. Link PRs to issues: `Closes #API-001`
4. Use project board to track in-progress, review, and done

## Git Workflow Guidance

All agents and team members must follow:

1. **Local development**: Commit to local git (`git add`, `git commit`)
2. **Local verification**: Confirm clean state (`git status`)
3. **Remote sync**: Push to remote and create PR
4. **Keep in sync**: Local and remote must always match

See `git-workflow.instructions.md` for detailed commands.

## Communication Cadence

- **Daily standups**: 15 min async update on blockers, progress
- **Code reviews**: PR reviews within 4 hours during business hours
- **Weekly sync**: 30 min full-team sync on Phase progress
- **Escalation**: Ping tech leads for blocked work or architecture questions
