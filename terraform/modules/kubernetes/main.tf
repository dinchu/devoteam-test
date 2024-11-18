# Create GKE cluster
resource "google_container_cluster" "my_cluster" {

  name     = var.name
  location = var.region

  #enable_autopilot = true #we take this one out to be able to manage our network config

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {

    #using the ranges from the predefined vpc subnets give us more control in the future
    cluster_secondary_range_name  = "pod-range" # Match the range_name in node_subnet
    services_secondary_range_name = "service-range"

  }

  # Avoid setting deletion_protection to false
  # until you're ready (and certain you want) to destroy the cluster.
  deletion_protection = false

  #to make this test cheap we don't want to spawn 3 nodes by default
  node_pool {
    name               = "default-pool"
    initial_node_count = 1

    autoscaling {
      min_node_count = 1
      max_node_count = 2
    }

    node_config {
      machine_type = "e2-standard-4" # smaller machines won't work
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  depends_on = [
    var.enable_google_apis
  ]

}