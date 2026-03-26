resource "google_cloud_firestore_database" "database" {
  project                     = var.gcp_project_id
  name                        = "(default)"
  location_id                 = var.region
  type                        = "FIRESTORE_NATIVE"
  delete_protection_state     = "DELETE_PROTECTION_ENABLED"
  deletion_policy             = "DELETE"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"

  depends_on = [google_project_service.firestore]
}

resource "google_firestore_security_rules" "rules" {
  project = var.gcp_project_id

  ruleset = file("${path.module}/firestore-rules.json")

  depends_on = [google_cloud_firestore_database.database]
}
