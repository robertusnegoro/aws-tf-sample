# GCP VPC Network
resource "google_compute_network" "main" {
  name                    = var.gcp_network_name
  auto_create_subnetworks = false
}

# GCP Subnet
resource "google_compute_subnetwork" "main" {
  name          = var.gcp_subnet_name
  ip_cidr_range = var.gcp_subnet_cidr
  network       = google_compute_network.main.id
  region        = var.gcp_region
}

# GCP Cloud Interconnect
resource "google_compute_interconnect_attachment" "main" {
  name                     = var.gcp_cloud_interconnect_name
  region                   = var.gcp_region
  type                     = "DEDICATED"
  router                   = google_compute_router.main.name
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  bandwidth               = var.gcp_cloud_interconnect_bandwidth
  project                 = var.gcp_project_id
}

# GCP Router
resource "google_compute_router" "main" {
  name    = "router-${var.gcp_cloud_interconnect_name}"
  network = google_compute_network.main.name
  region  = var.gcp_region
  project = var.gcp_project_id
}

# GCP Router Interface
resource "google_compute_router_interface" "main" {
  name       = "interface-${var.gcp_cloud_interconnect_name}"
  router     = google_compute_router.main.name
  region     = var.gcp_region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = null
  project    = var.gcp_project_id
}

# GCP Router BGP Peer
resource "google_compute_router_peer" "main" {
  name                      = "peer-${var.gcp_cloud_interconnect_name}"
  router                    = google_compute_router.main.name
  region                    = var.gcp_region
  peer_ip_address          = "169.254.0.2"
  peer_asn                 = 64512
  advertised_route_priority = 100
  interface                = google_compute_router_interface.main.name
  project                  = var.gcp_project_id
} 