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


#scripts for deployment
module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  platform              = "linux"
  additional_components = ["kubectl", "beta"]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "container clusters get-credentials ${var.name} --zone=${var.region} --project=${var.gcp_project_id}"
}

resource "null_resource" "delayed_script" {
  provisioner "local-exec" {
    command = <<EOT
      echo "I needed to add this delay since the cluster is not ready after instlalation";
      sleep 30;
      echo "Script execution after delay.";
    EOT
  }
}

resource "null_resource" "apply_deployment" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "kubectl apply -k ${var.filepath_manifest} -n ${var.namespace}"
  }

  depends_on = [
    module.gcloud,
    resource.null_resource.delayed_script
  ]
}


resource "null_resource" "wait_conditions" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = <<-EOT
    kubectl wait --for=condition=AVAILABLE apiservice/v1beta1.metrics.k8s.io --timeout=180s
    kubectl wait --for=condition=ready pods --all -n ${var.namespace} --timeout=390s
    EOT
  }

  depends_on = [
    resource.null_resource.apply_deployment
  ]
}
