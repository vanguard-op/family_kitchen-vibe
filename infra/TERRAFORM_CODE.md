# Family Kitchen Terraform Configuration Files

> This document contains the complete Terraform configuration code for GCP infrastructure. Copy each section to the corresponding `.tf` file.

---

## firestore.tf

```hcl
# Firestore database configuration with multi-region resilience

resource "google_firestore_database" "family_kitchen" {
  project     = var.gcp_project_id
  name        = "(default)"
  location_id = var.firestore_region
  type        = "FIRESTORE_NATIVE"
  
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
  delete_protection_state           = "DELETE_PROTECTION_ENABLED"
  
  depends_on = [google_project_service.required_apis]
}

# Collections Indexes
resource "google_firestore_index" "users_email" {
  project    = var.gcp_project_id
  collection = "users"
  field_config {
    field_path = "email"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "kingdoms_created_at" {
  project    = var.gcp_project_id
  collection = "kingdoms"
  field_config {
    field_path = "created_at"
    order      = "DESCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "members_kingdom_id" {
  project    = var.gcp_project_id
  collection = "members"
  field_config {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "members_user_kingdom" {
  project    = var.gcp_project_id
  collection = "members"
  field_config {
    field_path = "user_id"
    order      = "ASCENDING"
  }
  field_config {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "refresh_tokens_user" {
  project    = var.gcp_project_id
  collection = "refresh_tokens"
  field_config {
    field_path = "user_id"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "refresh_tokens_expires" {
  project    = var.gcp_project_id
  collection = "refresh_tokens"
  field_config {
    field_path = "expires_at"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "audit_logs_timestamp" {
  project    = var.gcp_project_id
  collection = "audit_logs"
  field_config {
    field_path = "timestamp"
    order      = "DESCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "audit_logs_event_type" {
  project    = var.gcp_project_id
  collection = "audit_logs"
  field_config {
    field_path = "event_type"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "audit_logs_kingdom_timestamp" {
  project    = var.gcp_project_id
  collection = "audit_logs"
  field_config {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  field_config {
    field_path = "timestamp"
    order      = "DESCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}

resource "google_firestore_index" "inventory_best_before" {
  project    = var.gcp_project_id
  collection = "kingdoms/{kingdom_id}/inventory"
  field_config {
    field_path = "best_before"
    order      = "ASCENDING"
  }
  field_config {
    field_path = "archived_at"
    order      = "ASCENDING"
  }
  database = google_firestore_database.family_kitchen.name
}
```

---

## cloud-run.tf

```hcl
# Cloud Run service configuration for FastAPI backend

resource "google_cloud_run_service" "family_kitchen_api" {
  name     = "family-kitchen-api"
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    spec {
      service_account_name = google_service_account.api_sa.email
      timeout_seconds      = 60
      containers {
        image = var.cloud_run_image
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        env {
          name  = "GCP_PROJECT_ID"
          value = var.gcp_project_id
        }
        env {
          name  = "FIRESTORE_PROJECT_ID"
          value = var.gcp_project_id
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }

        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 10
          period_seconds        = 5
        }

        startup_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 5
          period_seconds        = 5
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.cloud_run_min_instances
        "autoscaling.knative.dev/maxScale" = var.cloud_run_max_instances
        "run.googleapis.com/cloudsql-instances" = ""
        "run.googleapis.com/client-name" = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_apis,
    google_service_account.api_sa
  ]
}

# Make Cloud Run service public
resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.family_kitchen_api.name
  location = google_cloud_run_service.family_kitchen_api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "cloud_run_url" {
  value = google_cloud_run_service.family_kitchen_api.status[0].url
}
```

---

## iam.tf

```hcl
# Service accounts and IAM role bindings

# Cloud Run API Service Account
resource "google_service_account" "api_sa" {
  account_id   = "family-kitchen-api"
  display_name = "Family Kitchen API Service Account"
  project      = var.gcp_project_id

  depends_on = [google_project_service.required_apis]
}

# CI/CD Service Account  
resource "google_service_account" "cicd_sa" {
  account_id   = "family-kitchen-ci"
  display_name = "Family Kitchen CI/CD Service Account"
  project      = var.gcp_project_id

  depends_on = [google_project_service.required_apis]
}

# Cloud Run API - Firestore permissions
resource "google_project_iam_member" "api_firestore" {
  project = var.gcp_project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# Cloud Run API - Logging permissions
resource "google_project_iam_member" "api_logging" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# Cloud Run API - Secret Manager permissions
resource "google_project_iam_member" "api_secrets" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# CI/CD - Artifact Registry permissions
resource "google_project_iam_member" "cicd_artifact_registry" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# CI/CD - Cloud Run permissions
resource "google_project_iam_member" "cicd_cloud_run" {
  project = var.gcp_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# CI/CD - Secret Manager permissions
resource "google_project_iam_member" "cicd_secrets" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# Workload Identity Pool (for GitHub Actions)
resource "google_iam_workload_identity_pool" "github" {
  account_id                   = "github-pool"
  location                     = "global"
  display_name                 = "GitHub Actions Pool"
  project                      = var.gcp_project_id
  disabled                     = false
  session_duration             = "3600s"

  depends_on = [google_project_service.required_apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  account_id                 = google_iam_workload_identity_pool.github.account_id
  workload_identity_pool_id  = google_iam_workload_identity_pool.github.workload_identity_pool_id
  location                   = "global"
  provider_id                = "github-provider"
  attribute_mapping = {
    "google.subject"              = "assertion.sub"
    "attribute.actor"             = "assertion.actor"
    "attribute.aud"               = "assertion.aud"
    "attribute.repository"        = "assertion.repository"
  }
  project                    = var.gcp_project_id

  attribute_condition = "assertion.repository == 'vanguard-op/family_kitchen-vibe'"
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github" {
  service_account_id = google_service_account.cicd_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.gcp_project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/vanguard-op/family_kitchen-vibe"
}
```

---

## secret-manager.tf

```hcl
# Secret Manager configuration

# JWT Secret
resource "random_string" "jwt_secret" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "family-kitchen-jwt-secret-${var.environment}"
  project   = var.gcp_project_id

  replication {
    automatic = true
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "jwt_secret" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = random_string.jwt_secret.result
}

# Grant API service account access to JWT secret
resource "google_secret_manager_secret_iam_member" "api_jwt" {
  secret_id = google_secret_manager_secret.jwt_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

# Grant CI/CD service account access to JWT secret
resource "google_secret_manager_secret_iam_member" "cicd_jwt" {
  secret_id = google_secret_manager_secret.jwt_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd_sa.email}"
}

output "jwt_secret_id" {
  value       = google_secret_manager_secret.jwt_secret.id
  sensitive   = true
}
```

---

## networking.tf

```hcl
# Network security configuration

# Cloud Armor Security Policy
resource "google_compute_security_policy" "family_kitchen" {
  count = var.enable_cloud_armor ? 1 : 0
  name  = "family-kitchen-security-policy"
  description = "Cloud Armor DDoS protection"
  project = var.gcp_project_id

  # Block known malicious IPs
  rule {
    action   = "deny(403)"
    priority = "100"
    match {
      versioned_expr = "V1"
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }
    description = "SQL Injection Rule"
  }

  # Block XSS attacks
  rule {
    action   = "deny(403)"
    priority = "101"
    match {
      versioned_expr = "V1"
      expr {
        expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }
    description = "XSS Rule"
  }

  # Default rule to allow
  rule {
    action   = "allow"
    priority = "65535"
    match {
      versioned_expr = "V1"
      match_all {}
    }
    description = "Default rule"
  }

  depends_on = [google_project_service.required_apis]
}

# VPC Network
resource "google_compute_network" "family_kitchen" {
  name                    = "family-kitchen-network"
  project                 = var.gcp_project_id
  auto_create_subnetworks = true
}

# Cloud Router for NAT (for private Google access)
resource "google_compute_router" "family_kitchen" {
  name    = "family-kitchen-router"
  region  = var.gcp_region
  project = var.gcp_project_id
  network = google_compute_network.family_kitchen.name

  bgp {
    asn = 64514
  }
}

# Cloud NAT for private resources
resource "google_compute_router_nat" "family_kitchen" {
  name                               = "family-kitchen-nat"
  router                             = google_compute_router.family_kitchen.name
  region                             = google_compute_router.family_kitchen.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [google_project_service.required_apis]
}

# Private Google Access
resource "google_compute_network_peering_routes_config" "private_google_access" {
  peering = "private-google-access"
  network = google_compute_network.family_kitchen.name
  service = "googleapis.com"
}
```

---

## monitoring.tf

```hcl
# Cloud Logging and monitoring configuration

# Log sink for Firestore operations
resource "google_logging_project_sink" "firestore" {
  name        = "family-kitchen-firestore-logs"
  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/logs/firestore"
  
  filter = "resource.type=\"cloud_firestore_database\""
  
  unique_writer_identity = true

  depends_on = [google_project_service.required_apis]
}

# Log sink for Cloud Run
resource "google_logging_project_sink" "cloud_run" {
  name        = "family-kitchen-cloud-run-logs"
  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/logs/cloud-run"
  
  filter = "resource.type=\"cloud_run_revision\""
  
  unique_writer_identity = true

  depends_on = [google_project_service.required_apis]
}

# Error rate alert policy
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "Family Kitchen High Error Rate"
  combiner     = "OR"
  project      = var.gcp_project_id

  conditions {
    display_name = "Cloud Run Error Rate > 1%"
    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.response_code_class=\"5xx\""
      threshold_value = 0.01
      comparison      = "COMPARISON_GT"
      duration        = "300s"

      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = []

  enabled = true

  depends_on = [google_project_service.required_apis]
}

# Cloud Scheduler for backups
resource "google_cloud_scheduler_job" "firestore_backup" {
  count            = var.enable_firestore_backup ? 1 : 0
  name             = "family-kitchen-firestore-backup"
  description      = "Daily backup of Firestore database"
  schedule         = var.firestore_backup_schedule
  time_zone        = "UTC"
  attempt_deadline = "600s"
  project          = var.gcp_project_id
  region           = var.gcp_region

  http_target {
    http_method = "POST"
    uri         = "https://firestore.googleapis.com/v1/projects/${var.gcp_project_id}/databases/(default):backup"
    
    headers = {
      "Content-Type" : "application/json"
    }

    body = base64encode(jsonencode({
      backupConfig = {
        includedDatabases = ["(default)"]
      }
    }))

    oauth_token {
      service_account_email = google_service_account.backup_sa.email
    }
  }

  depends_on = [google_project_service.required_apis]
}

# Service account for backup scheduler
resource "google_service_account" "backup_sa" {
  account_id   = "family-kitchen-backup"
  display_name = "Family Kitchen Backup Service Account"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "backup_firestore" {
  project = var.gcp_project_id
  role    = "roles/datastore.backupAdmin"
  member  = "serviceAccount:${google_service_account.backup_sa.email}"
}
```

---

## firestore-rules.json

```json
{
  "rules": {
    "users": {
      "{user_id}": {
        ".read": "request.auth.uid == user_id",
        ".write": "request.auth.uid == user_id",
        ".validate": "newData.hasChildren(['email', 'password_hash', 'created_at'])"
      }
    },
    "kingdoms": {
      "{kingdom_id}": {
        ".read": "root.child('members').orderByChild('user_id').equalTo(request.auth.uid).val() != null",
        ".write": "get(/databases/$(database)/documents/members').where('kingdom_id', '==', kingdom_id).where('user_id', '==', request.auth.uid).where('role', 'in', ['King', 'Queen']).exists()",
        "members": {
          "{member_id}": {
            ".read": "get(/databases/$(database)/documents/kingdoms/$(kingdom_id)).data.members[request.auth.uid] != null",
            ".write": "get(/databases/$(database)/documents/members/$(member_id)).data.role in ['King', 'Queen']"
          }
        },
        "inventory": {
          "{item_id}": {
            ".read": "get(/databases/$(database)/documents/members').where('kingdom_id', '==', kingdom_id).where('user_id', '==', request.auth.uid).exists()",
            ".write": "get(/databases/$(database)/documents/members').where('kingdom_id', '==', kingdom_id).where('user_id', '==', request.auth.uid).where('role', 'in', ['King', 'Queen', 'Chef']).exists() || (get(/databases/$(database)/documents/members').where('kingdom_id', '==', kingdom_id).where('user_id', '==', request.auth.uid).where('role', 'in', ['Prince', 'Princess']).exists() && request.resource.data.category in ['inventory', 'pantry'])"
          }
        }
      }
    },
    "members": {
      "{member_id}": {
        ".read": "request.auth.uid != null",
        ".write": "get(/databases/$(database)/documents/kingdoms/$(resource.data.kingdom_id)).data.created_by == request.auth.uid"
      }
    },
    "refresh_tokens": {
      "{token_id}": {
        ".read": "request.auth.uid == resource.data.user_id",
        ".write": "request.auth.uid == resource.data.user_id",
        ".validate": "newData.hasChildren(['user_id', 'kingdom_id', 'token_hash', 'expires_at']) && newData.child('expires_at').val() > now"
      }
    },
    "audit_logs": {
      "{log_id}": {
        ".read": "get(/databases/$(database)/documents/kingdoms/$(resource.data.kingdom_id)).data.created_by == request.auth.uid || get(/databases/$(database)/documents/members').where('kingdom_id', '==', resource.data.kingdom_id).where('user_id', '==', request.auth.uid).where('role', 'in', ['King', 'Queen']).exists()",
        ".write": false,
        ".validate": "newData.hasChildren(['event_type', 'user_id', 'kingdom_id', 'timestamp'])"
      }
    }
  }
}
```

---

## terraform.tfvars.example

```hcl
gcp_project_id      = "your-gcp-project-id"
gcp_region          = "us-central1"
firestore_region    = "us-central"
environment         = "dev"
cloud_run_image     = "gcr.io/your-gcp-project-id/family-kitchen-api:latest"
enable_firestore_backup = true
enable_cloud_armor  = true
```

---

## dev.tfvars

```hcl
gcp_project_id       = "your-gcp-project-id"
gcp_region           = "us-central1"  
firestore_region     = "us-central"
environment          = "dev"
cloud_run_image      = "gcr.io/your-gcp-project-id/family-kitchen-api:latest"
cloud_run_min_instances = 1
cloud_run_max_instances = 3
log_retention_days   = 30
enable_firestore_backup = true
enable_cloud_armor   = false
create_state_bucket  = false
```

---

## staging.tfvars

```hcl
gcp_project_id       = "your-gcp-project-id"
gcp_region           = "us-central1"
firestore_region     = "us-central"
environment          = "staging"
cloud_run_image      = "gcr.io/your-gcp-project-id/family-kitchen-api:latest"
cloud_run_min_instances = 2
cloud_run_max_instances = 5
log_retention_days   = 60
enable_firestore_backup = true
enable_cloud_armor   = true
create_state_bucket  = false
```

---

## prod.tfvars

```hcl
gcp_project_id       = "your-gcp-project-id"
gcp_region           = "us-central1"
firestore_region     = "us-central"
environment          = "prod"
cloud_run_image      = "gcr.io/your-gcp-project-id/family-kitchen-api:latest"
cloud_run_min_instances = 2
cloud_run_max_instances = 10
log_retention_days   = 90
enable_firestore_backup = true
enable_cloud_armor   = true
create_state_bucket  = false
```

---

## How to Use This File

1. Copy each code block into the corresponding `.tf` file in the `infra/` directory
2. Ensure file names match exactly (e.g., `firestore.tf`, `cloud-run.tf`, etc.)
3. Replace placeholder values (GCP project ID, image URLs, etc.) with your actual values
4. Run `terraform fmt` to format all files consistently
5. Run `terraform validate` to check for syntax errors
6. Proceed with `terraform plan` and `terraform apply`
