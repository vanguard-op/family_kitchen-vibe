# Firestore Database
resource "google_firestore_database" "database" {
  project     = var.gcp_project_id
  name        = "(default)"
  location_id = var.firestore_region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.required_apis]
}

# Firestore Security Rules
resource "google_firestore_document" "security_rules" {
  project     = var.gcp_project_id
  database    = google_firestore_database.database.name
  collection  = "__rules__"
  document    = "security_rules"
  data = {
    rules = file("${path.module}/firestore-rules.json")
  }
}
