# Cloud Run service for API
resource "google_cloud_run_service" "api" {
  name     = "${var.app_name}-api-${var.environment}"
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    spec {
      service_account_name = google_service_account.api.email

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

        ports {
          container_port = 8000
        }

        resources {
          limits = {
            cpu    = var.cloud_run_cpu
            memory = var.cloud_run_memory
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.required_apis]
}

# IAM binding to allow unauthenticated access (for now)
resource "google_cloud_run_service_iam_binding" "api_public" {
  project    = var.gcp_project_id
  service    = google_cloud_run_service.api.name
  location   = google_cloud_run_service.api.location
  role       = "roles/run.invoker"
  members    = ["allUsers"]
  depends_on = [google_cloud_run_service.api]
}
