resource "google_service_account" "api" {
  account_id   = "${var.app_name}-api"
  display_name = "Service account for ${var.app_name} API"
  project      = var.gcp_project_id
}

resource "google_service_account" "ci_cd" {
  account_id   = "${var.app_name}-ci-cd"
  display_name = "Service account for ${var.app_name} CI/CD"
  project      = var.gcp_project_id
}

# API service account roles
resource "google_project_iam_member" "api_firestore" {
  project = var.gcp_project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api.email}"
}

resource "google_project_iam_member" "api_logging" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.api.email}"
}

resource "google_project_iam_member" "api_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api.email}"
}

# CI/CD service account roles
resource "google_project_iam_member" "ci_cd_artifact_registry" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

resource "google_project_iam_member" "ci_cd_cloud_run" {
  project = var.gcp_project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}
