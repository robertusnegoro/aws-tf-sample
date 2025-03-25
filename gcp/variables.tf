variable "environment" {
  description = "Environment name (staging or prod)"
  type        = string
  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "Environment must be either 'staging' or 'prod'."
  }
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "gcp_network_name" {
  description = "GCP Network name"
  type        = string
}

variable "gcp_subnet_name" {
  description = "GCP Subnet name"
  type        = string
}

variable "gcp_subnet_cidr" {
  description = "GCP Subnet CIDR"
  type        = string
  default     = "10.1.0.0/24"
}

variable "gcp_cloud_interconnect_name" {
  description = "GCP Cloud Interconnect name"
  type        = string
}

variable "gcp_cloud_interconnect_location" {
  description = "GCP Cloud Interconnect location"
  type        = string
}

variable "gcp_cloud_interconnect_bandwidth" {
  description = "GCP Cloud Interconnect bandwidth"
  type        = string
  default     = "10"
}

# AWS Transit Gateway information (from AWS output)
variable "aws_transit_gateway_id" {
  description = "AWS Transit Gateway ID"
  type        = string
} 