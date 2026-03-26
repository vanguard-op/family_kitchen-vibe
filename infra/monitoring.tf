resource "google_logging_project_sink" "audit_logs" {
  project = var.gcp_project_id
  name    = "${var.app_name}-audit-logs"

  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/locations/${var.region}/buckets/audit"

  filter = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="${var.app_name}-api"
    severity >= "WARNING"
  EOT
}

resource "google_monitoring_alert_policy" "high_error_rate" {
  project      = var.gcp_project_id
  display_name = "${var.app_name} High Error Rate"

  conditions {
    display_name = "Error rate > 1%"

    condition_threshold {
      filter          = <<-EOT
metric.type = "run.googleapis.com/request_count"
resource.service_name = "${var.app_name}-api"
metric.response_code_class = "5xx"
      EOT
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.01
    }
  }

  notification_channels = []
  alert_strategy {
    auto_close = "1800s"
  }
}
