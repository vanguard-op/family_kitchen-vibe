resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "${var.app_name}-jwt-secret"
  project   = var.gcp_project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "jwt_secret_version" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = base64encode(random_password.jwt_key.result)
}

resource "random_password" "jwt_key" {
  length  = 32
  special = true
}
