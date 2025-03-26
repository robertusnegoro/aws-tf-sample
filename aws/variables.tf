variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-3"
}

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

variable "aws_vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-southeast-3a", "ap-southeast-3b"]
}

variable "aws_direct_connect_location" {
  description = "Direct Connect location"
  type        = string
}

variable "aws_direct_connect_bandwidth" {
  description = "AWS Direct Connect bandwidth"
  type        = string
  default     = "1Gbps"
}

variable "aws_direct_connect_connection_name" {
  description = "Direct Connect connection name"
  type        = string
}

variable "aws_transit_gateway_name" {
  description = "Transit Gateway name"
  type        = string
}

# GCP Cloud Interconnect information (from GCP output)
variable "gcp_cloud_interconnect_attachment_id" {
  description = "GCP Cloud Interconnect attachment ID"
  type        = string
}

# Atlantis variables
variable "gitlab_token" {
  description = "GitLab personal access token"
  type        = string
  sensitive   = true
}

variable "gitlab_webhook_secret" {
  description = "GitLab webhook secret"
  type        = string
  sensitive   = true
}

variable "gitlab_base_url" {
  description = "GitLab base URL"
  type        = string
  default     = "https://gitlab.com"
} 