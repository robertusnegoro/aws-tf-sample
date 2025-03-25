terraform {
  backend "gcs" {
    bucket = "random-company-io-terraform-state"
    prefix = "gcp/terraform.tfstate"
  }
} 