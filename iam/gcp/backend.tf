terraform {
  backend "gcs" {
    bucket = "random-company-io-terraform-state"
    prefix = "iam/gcp/terraform.tfstate"
  }
} 