terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket  = "family-kitchen-terraform-state"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Main Terraform configuration for Family Kitchen GCP infrastructure
# Provider and backend setup

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket  = "family-kitchen-terraform-state"
    prefix  = "terraform/state"
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
  ])

  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = false
}
 Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "firestore.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com",
    "compute.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}
