variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "firestore_region" {
  description = "Firestore region (us-central for multi-region)"
  type        = string
  default     = "us-central"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "create_state_bucket" {
  description = "Whether to create the Terraform state bucket"
  type        = bool
  default     = false
}

variable "cloud_run_image" {
  description = "Cloud Run container image URL"
  type        = string
}

variable "cloud_run_min_instances" {
  description = "Minimum Cloud Run instances"
  type        = number
  default     = 1
}

variable "cloud_run_max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 10
}

variable "jwt_secret_length" {
  description = "Length of JWT secret in bytes"
  type        = number
  default     = 32
}

variable "firestore_backup_schedule" {
  description = "Cron schedule for Firestore backups (UTC)"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM UTC
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 90
}

variable "common_labels" {
  description = "Common labels applied to all resources"
  type        = map(string)
  default = {
    project    = "family-kitchen"
    managed_by = "terraform"
    version    = "1.0"
  }
}

variable "enable_firestore_backup" {
  description = "Enable automated Firestore backups"
  type        = bool
  default     = true
}

variable "enable_cloud_armor" {
  description = "Enable Cloud Armor DDoS protection"
  type        = bool
  default     = true
}

variable "app_name" {
  description = "Application name used in resource naming"
  type        = string
  default     = "family-kitchen"
}

variable "cloud_run_cpu" {
  description = "Cloud Run vCPU allocation (e.g. '1' or '2')"
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Cloud Run memory allocation (e.g. '512Mi' or '1Gi')"
  type        = string
  default     = "512Mi"
}
