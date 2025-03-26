# GCP Service Account for Terraform
resource "google_service_account" "terraform_service_account" {
  account_id   = "terraform-migration-sa"
  display_name = "Terraform Migration Service Account"
  description  = "Service account for running Terraform migrations"
  project      = var.project_id
}

# GCP Service Account Key
resource "google_service_account_key" "terraform_service_account" {
  service_account_id = google_service_account.terraform_service_account.name
}

# GCP Service Account IAM Policy
resource "google_project_iam_member" "terraform_service_account" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

# Additional required roles for the service account
resource "google_project_iam_member" "terraform_service_account_roles" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

# GCP IAM Group for Cloud Engineers
resource "google_cloud_identity_group" "cloud_engineers" {
  display_name         = "Cloud Engineers"
  initial_group_config = "WITH_INITIAL_OWNER"
  parent              = "customers/${var.customer_id}"
  group_key {
    id = "cloud-engineers@random-company.io"
  }
  labels = {
    environment = "production"
    purpose     = "cloud-engineers"
  }
}

# GCP IAM Policy for Cloud Engineers Group
resource "google_project_iam_member" "cloud_engineers" {
  for_each = toset([
    "roles/editor",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "group:cloud-engineers@random-company.io"
}

# Outputs
output "terraform_service_account_email" {
  value = google_service_account.terraform_service_account.email
}

output "terraform_service_account_key" {
  value     = base64decode(google_service_account_key.terraform_service_account.private_key)
  sensitive = true
} 