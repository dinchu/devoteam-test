# Create GKE cluster
resource "google_container_cluster" "my_cluster" {

  name     = var.name
  location = var.region
  
  #enable_autopilot = true #we take this one out to be able to manage our network config

  network  = google_compute_network.custom_vpc.id
  subnetwork = google_compute_subnetwork.node_subnet.name

  ip_allocation_policy {

     #using the ranges from the predefined vpc subnets give us more control in the future
    cluster_secondary_range_name  = "pod-range"       # Match the range_name in node_subnet
    services_secondary_range_name = "service-range" 

  }

  # Avoid setting deletion_protection to false
  # until you're ready (and certain you want) to destroy the cluster.
  deletion_protection = false

  initial_node_count = 1

  depends_on = [
    module.enable_google_apis
  ]

  node_config {
    machine_type = "e2-standard-4" # smaller machines won't work
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}