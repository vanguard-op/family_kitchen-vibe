output "firestore_database_id" {
  description = "Firestore database ID"
  value       = google_cloud_firestore_database.database.id
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.api.status[0].url
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.api.name
}

output "api_service_account_email" {
  description = "API service account email"
  value       = google_service_account.api.email
}

output "ci_cd_service_account_email" {
  description = "CI/CD service account email"
  value       = google_service_account.ci_cd.email
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc.id
}

output "security_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = google_compute_security_policy.policy.id
}
