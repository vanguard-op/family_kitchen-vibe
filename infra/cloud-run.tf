resource "google_cloud_run_service" "api" {
  name     = "${var.app_name}-api"
  location = var.region
  project  = var.gcp_project_id

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/${var.app_name}:latest"

        resources {
          limits = {
            cpu    = var.cloud_run_cpu
            memory = var.cloud_run_memory
          }
        }

        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.gcp_project_id
        }

        env {
          name  = "JWT_SECRET_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.jwt_secret.id
              key  = "latest"
            }
          }
        }
      }

      service_account_email = google_service_account.api.email
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run,
    google_service_account.api
  ]
}

# Allow public access to Cloud Run service
resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.api.name
  location = google_cloud_run_service.api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "cloud_build" {
  service  = google_cloud_run_service.api.name
  location = google_cloud_run_service.api.location
  role     = "roles/run.admin"
  member   = "serviceAccount:${google_service_account.ci_cd.email}"
}
