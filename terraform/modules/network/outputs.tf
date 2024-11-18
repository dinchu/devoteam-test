output "network_id" {
  value = google_compute_network.custom_vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.node_subnet.id
}
