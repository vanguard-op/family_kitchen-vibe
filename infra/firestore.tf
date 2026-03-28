# Firestore Database
resource "google_firestore_database" "database" {
  project     = var.gcp_project_id
  name        = "(default)"
  location_id = var.firestore_region
  type        = "FIRESTORE_NATIVE"

  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
  delete_protection_state           = "DELETE_PROTECTION_ENABLED"

  depends_on = [google_project_service.required_apis]
}

# Firestore Security Rules (deployed via Firebase Rules API)
resource "google_firebaserules_ruleset" "firestore" {
  project = var.gcp_project_id

  source {
    files {
      name    = "firestore.rules"
      content = file("${path.module}/firestore.rules")
    }
  }

  depends_on = [google_firestore_database.database]
}

resource "google_firebaserules_release" "firestore" {
  project      = var.gcp_project_id
  name         = "cloud.firestore"
  ruleset_name = google_firebaserules_ruleset.firestore.name

  depends_on = [google_firebaserules_ruleset.firestore]
}

# Composite index: expiring inventory items (GH-004 expiry alerts)
resource "google_firestore_index" "inventory_expiring" {
  project    = var.gcp_project_id
  database   = google_firestore_database.database.name
  collection = "inventory"

  fields {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  fields {
    field_path = "expires_at"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.database]
}

# Composite index: inventory items by kingdom sorted by created_at (GH-004)
resource "google_firestore_index" "inventory_kingdom_created" {
  project    = var.gcp_project_id
  database   = google_firestore_database.database.name
  collection = "inventory"

  fields {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.database]
}

# Composite index: members by kingdom and role (GH-002 role management)
resource "google_firestore_index" "members_kingdom_role" {
  project    = var.gcp_project_id
  database   = google_firestore_database.database.name
  collection = "members"

  fields {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  fields {
    field_path = "role"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.database]
}

# Composite index: members by kingdom and user_id (GH-001 kingdom lookup)
resource "google_firestore_index" "members_kingdom_user" {
  project    = var.gcp_project_id
  database   = google_firestore_database.database.name
  collection = "members"

  fields {
    field_path = "kingdom_id"
    order      = "ASCENDING"
  }
  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.database]
}
