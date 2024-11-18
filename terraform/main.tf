
locals {
  base_apis = [
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com"
  ]
  memorystore_apis = ["redis.googleapis.com"]
  cluster_name     = google_container_cluster.my_cluster.name
}
module "networking" {
  source  = "./modules/network"
  region  = var.region
}

module "enable_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0"

  project_id                  = var.gcp_project_id
  disable_services_on_destroy = false
  activate_apis = concat(local.base_apis, var.memorystore ? local.memorystore_apis : [])
}

module "kubernetes_gke" {
  source  = "./modules/kubernetes"
  region  = var.region
  network = module.networking.network_id
  subnetwork = module.networking.subnet_id
  project_id = var.gcp_project_id
}

module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  platform              = "linux"
  additional_components = ["kubectl", "beta"]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "container clusters get-credentials ${module.kubernetes_gke.cluster_name} --zone=${var.region} --project=${var.gcp_project_id}"
}

resource "null_resource" "apply_deployment" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "kubectl apply -k ${var.filepath_manifest} -n ${var.namespace}"
  }

  depends_on = [
    module.gcloud
  ]
}

resource "null_resource" "wait_conditions" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = <<-EOT
    kubectl wait --for=condition=AVAILABLE apiservice/v1beta1.metrics.k8s.io --timeout=180s
    kubectl wait --for=condition=ready pods --all -n ${var.namespace} --timeout=380s
    EOT
  }

  depends_on = [
    resource.null_resource.apply_deployment
  ]
}
