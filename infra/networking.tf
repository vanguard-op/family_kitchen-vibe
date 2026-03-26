resource "google_compute_network" "vpc" {
  project                 = var.gcp_project_id
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_router" "router" {
  project = var.gcp_project_id
  name    = "${var.app_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                    = var.gcp_project_id
  name                       = "${var.app_name}-nat"
  router                     = google_compute_router.router.name
  region                     = google_compute_router.router.region
  nat_ip_allocate_option     = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Cloud Armor security policy
resource "google_compute_security_policy" "policy" {
  project = var.gcp_project_id
  name    = "${var.app_name}-security-policy"

  # Allow all by default
  rules {
    action   = "allow"
    priority = 65535
    match {
      versioned_expr = "SOC_V1"
      expr {
        expression = "true"
      }
    }
    description = "Allow all traffic by default"
  }

  # Rate limiting rule: 50 requests per minute per IP
  rules {
    action   = "rate_based_ban"
    priority = 1000
    match {
      versioned_expr = "SOC_V1"
      expr {
        expression = "origin.region_code == 'US'"
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      rate_limit_threshold {
        count        = 50
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Ban IPs with >50 requests/min"
  }
}
