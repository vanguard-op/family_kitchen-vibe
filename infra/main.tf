# Main Terraform configuration for Family Kitchen GCP infrastructure
# Provider and backend setup
# Note: required_version and required_providers are declared in versions.tf

terraform {
  backend "gcs" {
    bucket = "family-kitchen-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Enable required Google Cloud APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "firestore.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "cloudscheduler.googleapis.com",
    "storage.googleapis.com",
    "servicenetworking.googleapis.com",
    "firebase.googleapis.com",
    "firebaserules.googleapis.com",
  ])

  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = false
}
