# Terraform configuration is now in versions.tf

# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "northamerica-northeast1"
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the service account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "github-actions"
  display_name = "GitHub Actions"
  description  = "Service account for GitHub Actions CI/CD pipeline"
}

# IAM roles to assign
locals {
  github_actions_roles = [
    "roles/run.admin",
    "roles/storage.admin",
    "roles/cloudbuild.builds.builder",
    "roles/iam.serviceAccountUser"  # Additional role often needed for Cloud Run
  ]
}

# Assign IAM roles to the service account
resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(local.github_actions_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Create a service account key (Note: This is stored in state - consider alternatives)
resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
  
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Outputs
output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.github_actions.email
}

output "service_account_key" {
  description = "Base64 encoded service account key (sensitive)"
  value       = google_service_account_key.github_actions_key.private_key
  sensitive   = true
}

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
} 
