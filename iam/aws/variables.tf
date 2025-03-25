variable "environment" {
  description = "Environment name (staging or prod)"
  type        = string
  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "Environment must be either 'staging' or 'prod'."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "terraform_service_account_name" {
  description = "Name of the Terraform service account"
  type        = string
}

variable "cloud_engineers_group_name" {
  description = "Name of the Cloud Engineers group"
  type        = string
}

variable "cloud_engineer_email" {
  description = "Email of the Cloud Engineer"
  type        = string
} 