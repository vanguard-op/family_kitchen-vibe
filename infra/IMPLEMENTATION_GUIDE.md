# Family Kitchen GCP Infrastructure - Implementation Guide

## Overview
This directory contains Terraform configuration for provisioning complete GCP infrastructure for Family Kitchen Phase 1, including Firestore, Cloud Run, service accounts, secrets management, and monitoring.

## File Structure

```
infra/
├── main.tf                    # Provider, backend, and API enablement
├── variables.tf               # Input variables for all environments
├── outputs.tf                 # Output values for service discovery
├── versions.tf                # Terraform and provider versions
├── firestore.tf               # Firestore database, collections, indexes
├── cloud-run.tf               # Cloud Run service configuration
├── iam.tf                      # Service accounts and IAM roles
├── secret-manager.tf          # Secret Manager resources
├── networking.tf              # VPC, firewall, Cloud Armor
├── monitoring.tf              # Cloud Logging and alerting
├── firestore-rules.json       # Firestore security rules
├── terraform.tfvars.example   # Example configuration
├── dev.tfvars                 # Development environment variables
├── staging.tfvars             # Staging environment variables
├── prod.tfvars                # Production environment variables
└── IMPLEMENTATION_GUIDE.md    # This file
```

## Setup Instructions

### 1. Initialize Terraform Backend

Before first deployment, create the GCS bucket for Terraform state:

```bash
export PROJECT_ID="your-gcp-project-id"

# Create bucket for Terraform state
gsutil mb -p ${PROJECT_ID} -c STANDARD -l us-central1 gs://family-kitchen-terraform-state-${PROJECT_ID}

# Enable versioning
gsutil versioning set on gs://family-kitchen-terraform-state-${PROJECT_ID}

# Enable encryption  
gsutil encryption set gs://family-kitchen-terraform-state-${PROJECT_ID}
```

### 2. Configure Environment Variables

```bash
export TF_VAR_gcp_project_id=${PROJECT_ID}
export TF_VAR_environment=dev
export TF_VAR_cloud_run_image=gcr.io/${PROJECT_ID}/family-kitchen-api:latest
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform with remote backend
terraform init -backend-config="bucket=family-kitchen-terraform-state-${PROJECT_ID}"

# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file="dev.tfvars" -out=tfplan

# Apply configuration
terraform apply tfplan
```

## Generated Terraform Files Content

### main.tf
Contains provider configuration, backend setup, and API enablement.

### firestore.tf
Creates Firestore database in Native mode with:
- Multi-region resilience (us-central)
- Point-in-time recovery enabled
- Automated daily backups
- Collections: users, kingdoms, members, refresh_tokens, audit_logs
- Composite indexes for efficient queries

### cloud-run.tf
Configures Cloud Run service with:
- Auto-scaling (1-10 instances based on traffic)
- Service account integration
- Environment variables
- Health check endpoint
- Request/response streaming

### iam.tf
Creates service accounts and IAM roles:
- `family-kitchen-api`: For Cloud Run (least-privilege roles)
- `family-kitchen-ci`: For GitHub Actions CI/CD
- Proper role delegation and permissions

### secret-manager.tf
Manages secrets:
- JWT signing keys (one per environment)
- Firestore credentials
- Secure secret storage with versioning

### networking.tf
Sets up network security:
- Cloud Armor DDoS protection
- Firewall rules for Cloud Run
- Private Google access
- VPC configuration

### monitoring.tf
Configures observability:
- Cloud Logging sinks for Firestore and Cloud Run
- 90-day log retention
- Error rate alerting
- Monitoring dashboard

### firestore-rules.json
Security rules enforcing:
- Multi-tenancy by kingdom_id partition
- Role-based access control (King, Queen, Prince, Princess, Chef, Visitor)
- PII encryption for email/allergies fields
- Authentication on all operations

## Deployment Checklist

- [ ] GCS state bucket created and encrypted
- [ ] GitHub secrets configured (GCP_PROJECT_ID, GCP_SA_KEY, GCP_REGION)
- [ ] tfvars files created for each environment
- [ ] Docker image pushed to Artifact Registry
- [ ] Terraform initialized with remote backend
- [ ] terraform plan reviewed and approved
- [ ] terraform apply executed
- [ ] Cloud Run service URL documented
- [ ] Firestore backups verified
- [ ] Security rules deployed
- [ ] Monitoring dashboard accessible
- [ ] Service account key created for CI/CD (if needed)

## Post-Deployment Validation

```bash
# Check Firestore database
gcloud firestore databases list --project=${PROJECT_ID}

# Check Cloud Run service
gcloud run services list --project=${PROJECT_ID}

# Check service accounts
gcloud iam service-accounts list --project=${PROJECT_ID}

# Check secrets
gcloud secrets list --project=${PROJECT_ID}

# Stream logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50 --project=${PROJECT_ID}
```

## Environment Management

### Development (dev.tfvars)
```hcl
environment = "dev"
cloud_run_max_instances = 3
log_retention_days = 30
enable_firestore_backup = true
```

### Staging (staging.tfvars)
```hcl
environment = "staging"
cloud_run_max_instances = 5
log_retention_days = 60
enable_firestore_backup = true
```

### Production (prod.tfvars)
```hcl
environment = "prod"
cloud_run_max_instances = 10
log_retention_days = 90
enable_firestore_backup = true
enable_cloud_armor = true
```

## Outputs

After terraform apply, the following values will be output:
- `firestore_database_id`: Reference to Firestore database
- `cloud_run_service_url`: Public URL of API backend
- `api_service_account_email`: Email of Cloud Run service account
- `ci_cd_service_account_email`: Email of CI/CD service account
- `jwt_secret_name`: Secret Manager reference for JWT key
- `log_sink_names`: Logging sink names for monitoring

## Troubleshooting

### State Lock Issues
```bash
terraform force-unlock <LOCK_ID>
```

### Service Account Key Issues
```bash
gcloud iam service-accounts keys create key.json --iam-account=family-kitchen-api@${PROJECT_ID}.iam.gserviceaccount.com
```

### Secret Access Issues
```bash
gcloud secrets add-iam-policy-binding family-kitchen-jwt-secret-dev \
  --member=serviceAccount:family-kitchen-api@${PROJECT_ID}.iam.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor
```

## Next Steps

1. Create actual Terraform .tf files based on the specifications in this guide
2. Configure GitHub Actions for automated deployments
3. Set up monitoring dashboards in Cloud Monitoring
4. Test Firestore security rules with emulator
5. Document API endpoints and deployment procedures
6. Create rollback procedures

## References

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Firestore Documentation](https://cloud.google.com/firestore/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/recommended-practices)
