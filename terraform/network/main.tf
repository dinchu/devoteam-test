resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks  = false  # Disabling automatic subnet creation
}

resource "google_compute_subnetwork" "node_subnet" {
  name          = "node-subnet"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  ip_cidr_range = "10.0.0.0/16"
  private_ip_google_access = true

  # Secondary ranges for Pods and Services
  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

output "network_id" {
  value = google_compute_network.custom_vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.node_subnet.id
}
