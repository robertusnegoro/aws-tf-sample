terraform {
  required_version = ">= 1.11.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.26.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.26.0"
    }
  }
} 