---
description: "Use when provisioning cloud infrastructure for family_kitchen. Covers Terraform, GCP services, IAM, Firestore, and deployment setup."
name: "Infrastructure - family_kitchen"
applyTo: "infra/**"
---

# Infrastructure for family_kitchen

## Project Context

- **Cloud Provider**: Google Cloud Platform (GCP)
- **IaC Tool**: Terraform
- **Region**: Configurable via `terraform.tfvars`
- **Main Services**: Cloud Run (API), Firestore, Cloud Storage, IAM
- **Infra Location**: `infra/` with Terraform modules
- **Project Phases**: Phase 1 (Core), Phase 2 (Extended), Phase 3 (Nice-to-have)

## Core Infrastructure Components

- **Cloud Run**: FastAPI backend service deployment
- **Firestore**: NoSQL database for family_kitchen data
- **Cloud Storage**: Document/media storage (photos, exports)
- **Cloud IAM**: Service account roles and permissions
- **Secret Manager**: API keys, third-party credentials
- **Cloud Monitoring**: Logs and metrics

## Issue Prefix

When creating GitHub issues for infrastructure work, use **`INFRA-`** prefix (e.g., `INFRA-001: Set up Firestore database and IAM`).

## Terraform Structure

- **`main.tf`**: Provider and primary resource definitions
- **`firestore.tf`**: Firestore database and security rules
- **`cloud-run.tf`**: Cloud Run service for API backend
- **`secret-manager.tf`**: Secrets and configuration management
- **`iam.tf`**: Service account roles and permissions
- **`variables.tf`**: Input variables for parametrization
- **`outputs.tf`**: Output values for cross-service reference
- **`terraform.tfvars.example`**: Template for local var files
- **`versions.tf`**: Provider versions and requirements

## Deployment Priorities

### Phase 1 (Core)
- GCP project and authentication setup
- Firestore database with security rules
- Cloud Run service for FastAPI backend
- Service account with minimal IAM roles
- Secret Manager for API credentials

### Phase 2 (Extended)
- Cloud Storage for file uploads
- Cloud Monitoring and logging
- Backup and disaster recovery setup
- CI/CD pipeline integration (GitHub Actions)

### Phase 3 (Nice-to-have)
- Advanced VPC networking
- Multi-region failover
- Performance analytics and optimization

## Security Requirements

- **Firestore Rules**: Enforce kingdom-level access control (`firestore-rules.json`)
- **IAM**: Least privilege for service accounts
- **Secrets**: All credentials in Secret Manager, never in code
- **Network**: Restrict Cloud Run ingress to authorized services
- **Audit**: Enable Cloud Audit Logs for compliance

## Testing & Validation

- Validate Terraform syntax: `terraform validate`
- Plan changes before apply: `terraform plan -out=tfplan`
- Review plan output for destructive changes
- Test Firestore security rules with test suite
- Verify IAM permissions post-deployment

## Git Workflow

1. **Local development**: Write/modify Terraform in `infra/` and commit to local git
2. **Verify**: Run `terraform validate` and review `terraform plan` locally
3. **Confirm**: Use `git status` to ensure clean working directory
4. **Remote sync**: After verification, push to remote branch and create PR
5. **Keep in sync**: Local and remote must always be in sync

## Deployment Process

1. Create feature branch for changes
2. Modify Terraform files in local git
3. Run `terraform plan` and review changes
4. Commit to local git
5. Push to remote and create PR for review
6. After PR approval, merge to main
7. CI/CD pipeline applies Terraform (or manual apply for caution)
