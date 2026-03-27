# Family Kitchen GCP Infrastructure Deployment Checklist

**Project**: Family Kitchen  
**Task**: Provision GCP Infrastructure & Firestore Database (TL-008)  
**Date**: March 27, 2026  
**Assigned to**: Cloud Engineering Team  

---

## Pre-Deployment Verification

### GCP Project Setup
- [ ] GCP project created or designated
- [ ] Billing enabled on project
- [ ] Project ID documented: `_________________`
- [ ] Region set to us-central1: `_________________`
- [ ] All team members have required IAM roles

### Prerequisites Installed
- [ ] Terraform 1.5+ installed: `` `terraform version` ``
- [ ] gcloud CLI installed: `gcloud --version`
- [ ] gcloud authenticated: `gcloud auth login`
- [ ] Docker installed (for future image builds)
- [ ] Python 3.7+ installed: `python3 --version`
- [ ] gsutil available (part of gcloud)

### Repository & Code
- [ ] Forked/cloned family_kitchen-vibe repository
- [ ] Checked out feature branch: `feat/infra-gcp` or similar
- [ ] Review SETUP_SUMMARY.md thoroughly
- [ ] Review README.md for infrastructure overview
- [ ] All Terraform files reviewed by tech lead

---

## Phase 1: Prepare Terraform Backend

### Create GCS Bucket

```bash
export PROJECT_ID="<your-gcp-project-id>"
export REGION="us-central1"
```

- [ ] PROJECT_ID environment variable set correctly
- [ ] REGION confirmed as us-central1

```bash
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION \
  gs://family-kitchen-terraform-state-$PROJECT_ID
```

- [ ] Command executed successfully
- [ ] Bucket created in console verification: https://console.cloud.google.com/storage

### Configure Bucket Settings

```bash
# Enable versioning
gsutil versioning set on gs://family-kitchen-terraform-state-$PROJECT_ID
```
- [ ] Versioning enabled

```bash
# Enable encryption
gsutil encryption set gs://family-kitchen-terraform-state-$PROJECT_ID
```
- [ ] Encryption enabled

### Verify Backend

```bash
gsutil ls -b gs://family-kitchen-terraform-state-$PROJECT_ID
```
- [ ] Bucket accessible from CLI

---

## Phase 2: Generate Terraform Files

### Option A: Using Python Script (Recommended)

```bash
cd infra/
python3 generate_terraform_files.py
```

- [ ] Script executed without errors
- [ ] Verify files created:
  - [ ] firestore.tf (created)
  - [ ] cloud-run.tf (created)
  - [ ] iam.tf (created)
  - [ ] secret-manager.tf (created)
  - [ ] networking.tf (created)
  - [ ] monitoring.tf (created)
  - [ ] terraform.tfvars.example (created)
  - [ ] dev.tfvars (created)
  - [ ] staging.tfvars (created)
  - [ ] prod.tfvars (created)

### Option B: Manual File Creation

If Python script fails:

- [ ] Copy firestore.tf content from TERRAFORM_CODE.md
- [ ] Copy cloud-run.tf content from TERRAFORM_CODE.md
- [ ] Copy iam.tf content from TERRAFORM_CODE.md
- [ ] Copy secret-manager.tf content from TERRAFORM_CODE.md
- [ ] Copy networking.tf content from TERRAFORM_CODE.md
- [ ] Copy monitoring.tf content from TERRAFORM_CODE.md
- [ ] Copy terraform.tfvars.example content from TERRAFORM_CODE.md
- [ ] Create dev.tfvars from template
- [ ] Create staging.tfvars from template
- [ ] Create prod.tfvars from template

### File Verification

```bash
ls -la infra/*.tf infra/*.tfvars infra/*.json
```

- [ ] All .tf files present (9+ files)
- [ ] All .tfvars files present (4 files)
- [ ] firestore-rules.json present

---

## Phase 3: Configure Environment Variables

### Update .tfvars Files

Edit each tfvars file with GCP project ID and image URLs:

**For dev.tfvars:**
```hcl
gcp_project_id = "YOUR_PROJECT_ID"
cloud_run_image = "gcr.io/YOUR_PROJECT_ID/family-kitchen-api:latest"
```

- [ ] dev.tfvars updated with PROJECT_ID
- [ ] dev.tfvars updated with container image URL
- [ ] dev.tfvars reviewed

**For staging.tfvars:**
```hcl
gcp_project_id = "YOUR_PROJECT_ID"
cloud_run_image = "gcr.io/YOUR_PROJECT_ID/family-kitchen-api:latest"
```

- [ ] staging.tfvars updated with PROJECT_ID
- [ ] staging.tfvars reviewed

**For prod.tfvars:**
```hcl
gcp_project_id = "YOUR_PROJECT_ID"
cloud_run_image = "gcr.io/YOUR_PROJECT_ID/family-kitchen-api:latest"
```

- [ ] prod.tfvars updated with PROJECT_ID
- [ ] prod.tfvars reviewed by tech lead

### Set Shell Environment

```bash
export TF_VAR_gcp_project_id=$PROJECT_ID
export TF_VAR_environment=dev
export TF_VAR_cloud_run_image="gcr.io/$PROJECT_ID/family-kitchen-api:latest"
```

- [ ] TF_VAR_gcp_project_id exported
- [ ] TF_VAR_environment exported
- [ ] TF_VAR_cloud_run_image exported
- [ ] Variables verified: `echo $TF_VAR_gcp_project_id`

---

## Phase 4: Initialize Terraform

### Initialize Backend

```bash
cd infra/
terraform init -backend-config="bucket=family-kitchen-terraform-state-$PROJECT_ID"
```

- [ ] terraform init completed successfully
- [ ] Remote state backend configured
- [ ] No errors in output
- [ ] .terraform directory created

### Validate Configuration

```bash
terraform validate
```

- [ ] Validation passed
- [ ] All variable references correct
- [ ] No syntax errors

### Format Code

```bash
terraform fmt -recursive
```

- [ ] Code formatted consistently
- [ ] Changes reviewed: `git diff infra/`

### Verify Variables

```bash
terraform plan -var-file="dev.tfvars"
```

- [ ] Variable values correct in plan output
- [ ] gcp_project_id visible in plan
- [ ] environment set to "dev"

---

## Phase 5: Create Terraform Plan

### Plan for Dev Environment

```bash
terraform plan -var-file="dev.tfvars" -out=tfplan
```

- [ ] Plan created successfully
- [ ] Output saved to tfplan file
- [ ] Review resource count
- [ ] Review major resources to be created:
  - [ ] google_firestore_database
  - [ ] google_cloud_run_service
  - [ ] google_service_account (3 accounts)
  - [ ] google_secret_manager_secret
  - [ ] google_logging_project_sink (2 sinks)
  - [ ] google_cloud_scheduler_job (for backups)

### Review Plan Output

```bash
terraform show tfplan | tee tfplan_output.txt
```

- [ ] Plan output saved
- [ ] Plan reviewed for accuracy
- [ ] No unexpected resource deletions
- [ ] All resources named correctly
- [ ] Tech lead approval obtained

### Estimate Costs

- [ ] Estimated monthly cost reviewed
- [ ] Within budget constraints
- [ ] Cost estimation documented

---

## Phase 6: Apply Terraform Configuration

### First-Time Apply

```bash
terraform apply tfplan
```

- [ ] Apply execution started
- [ ] API enablement in progress (can take 2-3 minutes)
- [ ] Resources being created...

### Monitor Apply Progress

During `terraform apply`:

- [ ] Firestore database created
  - Expected time: ~2-3 minutes
  - Check: `gcloud firestore databases list`

- [ ] Service accounts created
  - Expected: 3 accounts created
  - Check: `gcloud iam service-accounts list`

- [ ] Cloud Run service deployed
  - Expected time: ~1-2 minutes
  - Check: `gcloud run services list`

- [ ] Secrets created
  - Expected: 1 JWT secret
  - Check: `gcloud secrets list`

- [ ] Logging infrastructure created
  - Expected time: ~30 seconds
  - Check: `gcloud logging sinks list`

### Handle Errors During Apply

If errors occur:

- [ ] Note the error message and resource
- [ ] Check Cloud Console for more details
- [ ] Review TROUBLESHOOTING section in README.md
- [ ] Do NOT run apply again without resolution
- [ ] Contact tech lead if unclear

### Apply Completion

```bash
terraform apply tfplan
# Should complete with:
# Apply complete! Resources: N added, 0 changed, 0 destroyed.
```

- [ ] Apply completed successfully (✓ All resources created)
- [ ] Errors count: 0
- [ ] Resources created count: ____ (typically 40+)
- [ ] Apply log saved: `terraform apply tfplan > apply_log.txt 2>&1`

---

## Phase 7: Retrieve and Verify Outputs

### Get Terraform Outputs

```bash
terraform output
```

Record the following outputs:

- [ ] **firestore_database_id**: `_____________________`
- [ ] **cloud_run_service_url**: `_____________________`
- [ ] **api_service_account_email**: `_____________________`
- [ ] **ci_cd_service_account_email**: `_____________________`
- [ ] **jwt_secret_name**: `_____________________`

### Verify Firestore Setup

```bash
gcloud firestore databases list --project=$PROJECT_ID
```

- [ ] Database "(default)" visible in list
- [ ] Region: us-central (multi-region)
- [ ] Type: FIRESTORE_NATIVE

```bash
gcloud firestore indexes list --project=$PROJECT_ID
```

- [ ] At least 10+ indexes created
- [ ] Indexes for all collections visible
- [ ] Composite indexes for complex queries visible

### Verify Cloud Run Service

```bash
gcloud run services list --project=$PROJECT_ID
```

- [ ] Service "family-kitchen-api" visible
- [ ] Region: us-central1
- [ ] Status: OK

```bash
API_URL=$(terraform output -raw cloud_run_service_url)
echo "API URL: $API_URL"
```

- [ ] URL retrieved successfully
- [ ] URL format: https://family-kitchen-api-***.run.app

### Test Health Endpoint

```bash
curl -I $API_URL/health
```

- [ ] HTTP 200 or 404 OK (endpoint may not be implemented yet)
- [ ] Service is accessible
- [ ] No timeout errors

### Verify Service Accounts

```bash
gcloud iam service-accounts list --project=$PROJECT_ID
```

- [ ] family-kitchen-api@PROJECT_ID.iam.gserviceaccount.com (ACTIVE)
- [ ] family-kitchen-ci@PROJECT_ID.iam.gserviceaccount.com (ACTIVE)
- [ ] family-kitchen-backup@PROJECT_ID.iam.gserviceaccount.com (ACTIVE)

### Verify Secret Manager

```bash
gcloud secrets list --project=$PROJECT_ID
```

- [ ] family-kitchen-jwt-secret-dev visible
- [ ] Version 1 created

```bash
# Verify access (may deny depending on IAM)
gcloud secrets versions access latest --secret=family-kitchen-jwt-secret-dev \
  --project=$PROJECT_ID
```

- [ ] Secret accessible or permission denied (expected)

### Verify Logging

```bash
gcloud logging sinks list --project=$PROJECT_ID
```

- [ ] family-kitchen-firestore-logs visible
- [ ] family-kitchen-cloud-run-logs visible

```bash
gcloud logging read "resource.type=cloud_run_revision" --limit 10 \
  --project=$PROJECT_ID
```

- [ ] Cloud Run logs present
- [ ] No errors in recent logs (expected, no traffic yet)

---

## Phase 8: GitHub Configuration

### Create Service Account Key (if not using Workload Identity)

```bash
gcloud iam service-accounts keys create cicd-key.json \
  --iam-account=family-kitchen-ci@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID
```

- [ ] Service account key created
- [ ] cicd-key.json file generated locally

### Encode Key for GitHub Secrets

```bash
cat cicd-key.json | base64 -w 0
```

- [ ] Base64-encoded key copied to clipboard

### Add GitHub Repository Secrets

Settings → Secrets → New repository secret

- [ ] **GCP_PROJECT_ID**: `<your-gcp-project-id>`
- [ ] **GCP_REGION**: `us-central1`
- [ ] **GCP_SA_KEY**: `<base64-encoded service account JSON>`
- [ ] **GCP_WORKLOAD_IDENTITY_PROVIDER**: `<provider ID if using federation>`

After adding secrets:

- [ ] Verified in GitHub UI
- [ ] Secrets show as "••••••" (masked)
- [ ] Correct number of secrets added (3-4)

### Secure Local Key File

```bash
rm cicd-key.json  # Delete local copy
# OR use secure storage if needed
```

- [ ] Local cicd-key.json deleted (DO NOT commit!)
- [ ] Verified not in .gitignore additions

---

## Phase 9: Initialize Backend Data

### Create Initial Firestore Documents

If backend exists, manually or via script:

```bash
# Example: Create sample kingdom
gcloud firestore documents create kingdoms/kingdom-001 \
  --data="name=Sample Kingdom,created_by=user-001,created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --project=$PROJECT_ID
```

- [ ] Sample test data created in Firestore (optional)
- [ ] Verified in Firestore console

### Deploy Backend Service

- [ ] Backend service container built and pushed to Artifact Registry
- [ ] Cloud Run revision deployed with container
- [ ] Health check returning 200

```bash
curl $API_URL/health
```

- [ ] API health endpoint responds
- [ ] Status code: 200

---

## Phase 10: Security Verification

### Verify IAM Permissions

```bash
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:family-kitchen-api@*"
```

- [ ] API service account has exactly: datastore.user, logging.logWriter, secretmanager.secretAccessor
- [ ] No overprivileged roles

```bash
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:family-kitchen-ci@*"
```

- [ ] CI/CD service account has exactly: artifactregistry.admin, run.admin, secretmanager.secretAccessor
- [ ] No overprivileged roles

### Verify Firestore Security Rules

```bash
firebase functions:config:set env.project=$PROJECT_ID  # If using Firebase CLI
firebase deploy --only firestore:rules
# OR deploy via console
```

- [ ] Firestore security rules deployed
- [ ] Rules enforce multi-tenancy
- [ ] Rules prevent unauthorized access

### Verify Cloud Armor

```bash
gcloud compute security-policies list --project=$PROJECT_ID
```

- [ ] family-kitchen-security-policy visible
- [ ] Rules configured:
  - [ ] SQL injection rule
  - [ ] XSS prevention rule

### Verify Network Security

```bash
gcloud compute networks list --project=$PROJECT_ID
```

- [ ] family-kitchen-network visible

```bash
gcloud compute routers list --project=$PROJECT_ID
```

- [ ] family-kitchen-router visible

---

## Phase 11: Testing & Validation

### Test Firestore Connectivity

Deploy test query to Cloud Run:

```bash
curl -X POST $API_URL/api/v1/kingdoms/test \
  -H "Authorization: Bearer <test-token>" \
  -H "Content-Type: application/json"
```

- [ ] Cloud Run successfully queries Firestore
- [ ] Multi-tenancy isolation working (returns only kingdom data)
- [ ] No CORS or auth errors

### Load Testing (Optional)

```bash
gcloud compute backend-services create family-kitchen-backend \
  --protocol=HTTP \
  --global
# Or use Cloud Load Testing UI
```

- [ ] Load testing completed
- [ ] Cloud Run auto-scaling verified
- [ ] Performance within SLA

### Security Testing (Optional)

- [ ] OWASP top 10 vulnerability checking
- [ ] Firestore rule validation
- [ ] IAM least-privilege verification

---

## Phase 12: Documentation & Handoff

### Update Documentation

- [ ] API endpoint URL documented: `______________________`
- [ ] Firestore database reference documented
- [ ] Service account emails documented
- [ ] Deployment procedures documented (ops/runbook)

### Create Runbook

- [ ] Common troubleshooting steps documented
- [ ] Escalation procedures defined
- [ ] Emergency contact list created

### Archive Deployment Artifact

```bash
tar -czf family-kitchen-infra-$(date +%Y%m%d).tar.gz infra/
```

- [ ] Deployment tarball created
- [ ] Uploaded to secure storage
- [ ] Checksum saved

### Notify Team

- [ ] Sent channel message with infrastructure ready
- [ ] Shared Terraform outputs
- [ ] Shared API endpoint URL
- [ ] Scheduled knowledge transfer session

---

## Sign-Off

### Tech Lead Review

- [ ] Infrastructure code reviewed
- [ ] Deployment plan approved
- [ ] Security controls verified

**Approved by**: ____________________  
**Date**: ____________________  
**Comments**: ________________________________________________________________

### DevOps/Cloud Engineering

- [ ] Deployment completed successfully
- [ ] All acceptance criteria met
- [ ] Production ready

**Completed by**: ____________________  
**Date**: ____________________  
**Issues encountered**: _________________________________________________________

### Backend Team

- [ ] Backend integrated with infrastructure
- [ ] API endpoints working
- [ ] Ready for testing

**Confirmed by**: ____________________  
**Date**: ____________________  

---

## Post-Deployment (Operations)

### First Week

- [ ] Monitor logs daily for errors
- [ ] Check cost against estimates
- [ ] Verify auto-scaling works (if under load)
- [ ] Complete knowledge transfer sessions
- [ ] Document lessons learned

### Ongoing

- [ ] Weekly cost reviews
- [ ] Monthly security audit
- [ ] Quarterly disaster recovery drills
- [ ] Backup restoration testing
- [ ] Dependency updates and patches

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Terraform plan fails | Check `terraform validate`, gcloud auth login |
| Apply hangs on API enablement | Wait 2-3 minutes, API services take time to activate |
| Cloud Run service not responding | Check Cloud Run logs, verify service account permissions |
| Firestore queries timeout | Verify indexes are built, check Cloud Logging |
| Permission denied on secrets | Verify service account IAM role binding |
| State lock errors | Run `terraform force-unlock <LOCK_ID>` |

---

**Checklist Version**: 1.0  
**Last Updated**: March 27, 2026  
**Status**: Ready for Deployment ✅
