output "gcp_cloud_interconnect_attachment_id" {
  description = "ID of the GCP Cloud Interconnect attachment"
  value       = google_compute_interconnect_attachment.main.id
}

output "gcp_router_id" {
  description = "ID of the GCP Router"
  value       = google_compute_router.main.id
}

output "gcp_network_id" {
  description = "ID of the GCP Network"
  value       = google_compute_network.main.id
}

output "gcp_subnet_id" {
  description = "ID of the GCP Subnet"
  value       = google_compute_subnetwork.main.id
} 