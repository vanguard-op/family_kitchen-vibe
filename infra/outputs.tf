output "firestore_database" {
  description = "Firestore database reference"
  value       = google_firestore_database.database.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.api.status[0].url
}

output "service_account" {
  description = "Service account email"
  value       = google_service_account.api.email
}
