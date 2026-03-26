# Service Account for API
resource "google_service_account" "api" {
  account_id   = "${var.app_name}-api-${var.environment}"
  display_name = "${var.app_name} API Service Account"
  project      = var.gcp_project_id
}

# Firestore access role
resource "google_project_iam_member" "api_firestore" {
  project = var.gcp_project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api.email}"
}

# Logging role
resource "google_project_iam_member" "api_logging" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.api.email}"
}

# Secret Manager access
resource "google_project_iam_member" "api_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api.email}"
}
