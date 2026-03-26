# Deployment Guide

## Prerequisites

- GCP project with billing enabled
- Terraform CLI v1.5+
- Docker
- gcloud CLI
- GitHub repository with secrets configured

## GCP Setup

1. Create GCP project:
   ```bash
   gcloud projects create family-kitchen-prod --name="Family Kitchen - The Royal Hearth"
   gcloud config set project family-kitchen-prod
   ```

2. Enable billing:
   ```bash
   gcloud billing projects link family-kitchen-prod --billing-account={BILLING_ACCOUNT_ID}
   ```

3. Create service account:
   ```bash
   gcloud iam service-accounts create family-kitchen-deployment --display-name="Family Kitchen Deployment"
   ```

4. Grant permissions:
   ```bash
   gcloud projects add-iam-policy-binding family-kitchen-prod \
     --member="serviceAccount:family-kitchen-deployment@family-kitchen-prod.iam.gserviceaccount.com" \
     --role="roles/editor"
   ```

5. Create and download key:
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=family-kitchen-deployment@family-kitchen-prod.iam.gserviceaccount.com
   ```

## GitHub Secrets

Add the following secrets to your GitHub repository:

- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_SA_KEY`: Contents of `key.json` (base64 encoded)

## Terraform Deployment

1. Configure backend:
   ```bash
   cd infra
   gsutil mb gs://family-kitchen-terraform-state/
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="bucket=family-kitchen-terraform-state"
   ```

3. Review plan:
   ```bash
   terraform plan
   ```

4. Apply configuration:
   ```bash
   terraform apply
   ```

## Backend Deployment

1. Build and push Docker image:
   ```bash
   cd api
   docker build -t gcr.io/{PROJECT_ID}/family-kitchen-api:v0.1.0 .
   docker push gcr.io/{PROJECT_ID}/family-kitchen-api:v0.1.0
   ```

2. Deploy to Cloud Run:
   ```bash
   gcloud run deploy family-kitchen-api-prod \
     --image gcr.io/{PROJECT_ID}/family-kitchen-api:v0.1.0 \
     --platform managed \
     --region us-central1 \
     --set-env-vars ENVIRONMENT=production,GCP_PROJECT_ID={PROJECT_ID}
   ```

## Mobile Deployment

### Android

1. Build APK:
   ```bash
   cd mobile_app
   flutter build apk --release --split-per-abi
   ```

2. Upload to Google Play Store:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create app entry
   - Upload APK to internal testing track

### iOS

1. Build IPA:
   ```bash
   flutter build ios --release
   ```

2. Upload to App Store:
   - Use Xcode or Apple Transporter
   - Submit for review

## Monitoring

View logs and metrics:

```bash
# Cloud Run logs
gcloud run services list
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Firestore metrics
gcloud firestore operations list
```

## Rollback

If deployment fails, roll back to previous version:

```bash
gcloud run deploy family-kitchen-api-prod \
  --image gcr.io/{PROJECT_ID}/family-kitchen-api:previous-tag
```
