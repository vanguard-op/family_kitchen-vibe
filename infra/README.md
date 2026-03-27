# Family Kitchen GCP Infrastructure

Complete Terraform configuration for provisioning Family Kitchen Phase 1 infrastructure on Google Cloud Platform.

## 📋 Overview

This directory contains production-ready Terraform code for:
- **Firestore**: Native mode with multi-region resilience and point-in-time recovery
- **Cloud Run**: FastAPI backend with auto-scaling and health checks
- **Service Accounts**: Least-privilege IAM roles for API and CI/CD
- **Secret Manager**: Secure JWT key and credential management  
- **Cloud Logging**: Audit trails and error monitoring
- **Cloud Armor**: DDoS protection and security policies
- **Workload Identity**: GitHub Actions integration

## 🚀 Quick Start

### Prerequisites
- GCP Project with billing enabled
- Terraform 1.5+
- gcloud CLI configured
- Docker installed (for building container images)

### 1. Setup Terraform State Backend

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

# Create GCS bucket for state
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://family-kitchen-terraform-state-$PROJECT_ID

# Enable versioning
gsutil versioning set on gs://family-kitchen-terraform-state-$PROJECT_ID

# Enable encryption
gsutil encryption set gs://family-kitchen-terraform-state-$PROJECT_ID
```

### 2. Generate Terraform Files

The infrastructure uses a Python script to generate individual `.tf` files from templates. Run:

```bash
# Option 1: Using Python directly
python3 generate_terraform_files.py

# Option 2: Using bash (if Python not available)
# Manually copy content from TERRAFORM_CODE.md to individual files
```

### 3. Initialize and Deploy

```bash
# Set environment variables
export TF_VAR_gcp_project_id=$PROJECT_ID
export TF_VAR_environment=dev
export TF_VAR_cloud_run_image="gcr.io/$PROJECT_ID/family-kitchen-api:latest"

# Initialize with remote backend
terraform init -backend-config="bucket=family-kitchen-terraform-state-$PROJECT_ID"

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment
terraform plan -var-file="dev.tfvars" -out=tfplan

# Apply configuration
terraform apply tfplan
```

## 📁 File Structure

```
infra/
├── versions.tf                 # Terraform & provider versions
├── main.tf                     # Provider config & API enablement
├── variables.tf                # Input variables (80+ lines)
├── outputs.tf                  # Output values for service discovery
├── firestore.tf                # Firestore database & indexes
├── cloud-run.tf                # Cloud Run service setup
├── iam.tf                      # Service accounts & IAM roles
├── secret-manager.tf           # Secret Manager resources
├── networking.tf               # VPC, NAT, Cloud Armor
├── monitoring.tf               # Logging, alerting, backup scheduler
├── firestore-rules.json        # Firestore security rules (RBAC)
├── terraform.tfvars.example    # Example configuration
├── dev.tfvars                  # Development environment
├── staging.tfvars              # Staging environment
├── prod.tfvars                 # Production environment
├── IMPLEMENTATION_GUIDE.md     # Detailed setup instructions
├── TERRAFORM_CODE.md           # Source code for all .tf files
├── generate_terraform_files.py # Python script to generate files
└── README.md                   # This file
```

## 🔧 Configuration

### Environment Variables (in .tfvars)

**Required for all environments:**
- `gcp_project_id`: GCP Project ID
- `environment`: dev, staging, or prod
- `cloud_run_image`: Container image URL

**Optional:**
- `cloud_run_min_instances`: Min Cloud Run replicas (default: 1)
- `cloud_run_max_instances`: Max Cloud Run replicas (default: 10)
- `enable_firestore_backup`: Enable automated backups (default: true)
- `enable_cloud_armor`: Enable DDoS protection (default: true)

### Firestore Collections

Automatically created with indexes:
- `users`: Email index for authentication lookup
- `kingdoms`: Sorted by creation date
- `members`: Indexed by kingdom_id and user_id pair
- `refresh_tokens`: Indexed by user_id and expiration
- `audit_logs`: Indexed by timestamp and event type

### Service Accounts

**family-kitchen-api** (Cloud Run)
- `roles/datastore.user`: Firestore read/write
- `roles/logging.logWriter`: Write logs
- `roles/secretmanager.secretAccessor`: Read JWT secrets

**family-kitchen-ci** (GitHub Actions)
- `roles/artifactregistry.admin`: Manage images
- `roles/run.admin`: Deploy Cloud Run
- `roles/secretmanager.secretAccessor`: Read secrets

**family-kiss-backup** (Backup Scheduler)
- `roles/datastore.backupAdmin`: Create Firestore backups

## 📊 Outputs

After `terraform apply`, get outputs via:

```bash
terraform output

# Or retrieve specific outputs:
terraform output cloud_run_service_url
terraform output firestore_database_id
terraform output api_service_account_email
```

Key outputs:
- `cloud_run_service_url`: Public API endpoint
- `firestore_database_id`: Database reference
- `api_service_account_email`: Service account for API
- `ci_cd_service_account_email`: Service account for CI/CD
- `jwt_secret_name`: Secret Manager JWT key reference

## 🔐 Security Features

✅ **Multi-tenancy Enforcement**: All queries scoped by kingdom_id partition
✅ **Role-Based Access Control**: King, Queen, Prince, Princess, Chef, Visitor roles
✅ **Least-Privilege IAM**: Service accounts limited to required permissions
✅ **Secret Encryption**: Secrets stored in Secret Manager with KMS encryption
✅ **Cloud Armor**: DDoS protection with SQL injection + XSS rules
✅ **Audit Logging**: All operations logged to Cloud Logging
✅ **Point-in-Time Recovery**: Firestore PITR enabled for backups

## 🚨 Important Notes

1. **State File Security**
   - Terraform state contains sensitive data
   - Always use remote backend (GCS) with encryption
   - Never commit `.tfstate` files to Git

2. **Service Account Keys**
   - For CI/CD, create service account keys and store in GitHub Secrets
   - Rotate keys regularly
   - Never commit keys to source control

3. **Firestore Backup**
   - Scheduled daily at 2 AM UTC via Cloud Scheduler
   - Retention: Project must have backup storage configured
   - Test restore procedures regularly

4. **Cost Estimation**
   - Firestore: $0.06/100K reads, $0.18/100K writes
   - Cloud Run: $0.00002400 per CPU-second, $0.0000050 per GB-second
   - Cloud Logging: $0.50 per GB ingested
   - See [GCP Pricing](https://cloud.google.com/pricing) for estimates

## 🧪 Validation

```bash
# Test Firestore collections and indexes
gcloud firestore databases list --project=$PROJECT_ID
gcloud firestore indexes list --project=$PROJECT_ID

# Test Cloud Run service
gcloud run services list --project=$PROJECT_ID
curl $(terraform output -raw cloud_run_service_url)/health

# Test secrets are accessible
gcloud secrets versions access latest --secret=family-kitchen-jwt-secret-dev --project=$PROJECT_ID

# Check logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50 --project=$PROJECT_ID
```

## 🐛 Troubleshooting

### Terraform State Lock
```bash
terraform force-unlock <LOCK_ID>
```

### Service Account Permission Errors
```bash
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:family-kitchen-api@*"
```

### Cloud Run Service Not Accessible
```bash
gcloud run services get-iam-policy family-kitchen-api \
  --region=us-central1 --project=$PROJECT_ID
```

### Firestore Rules Errors
Deploy rules via:
```bash
firebase deploy --only firestore:rules
# or via console
```

## 📖 Next Steps

1. **Deploy Backend**: Push FastAPI container to Artifact Registry
2. **Configure GitHub Actions**: Set up CI/CD with Workload Identity
3. **Create Firestore Documents**: Initialize seed data for kingdoms/users
4. **Monitor**: Set up Cloud Monitoring dashboards
5. **Test**: Run load tests via Cloud Load Testing
6. **Document**: Create API documentation with OpenAPI spec

## 📚 References

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Firestore Best Practices](https://cloud.google.com/firestore/docs/best-practices)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)  
- [Google Cloud IAM](https://cloud.google.com/iam/docs)
- [Workload Identity Federation](https://cloud.google.com/docs/authentication/workload-identity-federation)

## 💡 Support

For issues or questions:
1. Check [Terraform Google Provider Issues](https://github.com/hashicorp/terraform-provider-google/issues)
2. Review [Google Cloud Documentation](https://cloud.google.com/docs)
3. See repository issues and documentation

---

**Last Updated**: March 2026  
**Terraform Version**: 1.5+  
**Google Provider Version**: 5.0+
