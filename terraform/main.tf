locals {
  base_apis = [
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com"
  ]
  memorystore_apis = ["redis.googleapis.com"]
}

module "network" {
  source = "./modules/network"
  region = var.region
}

module "enable_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0"

  project_id                  = var.gcp_project_id
  disable_services_on_destroy = false
  activate_apis               = concat(local.base_apis, var.memorystore ? local.memorystore_apis : [])
}

module "kubernetes" {
  source             = "./modules/kubernetes"
  region             = var.region
  network            = module.network.network_id
  subnetwork         = module.network.subnet_id
  name               = var.name
  namespace          = var.namespace
  gcp_project_id     = var.gcp_project_id
  memorystore        = var.memorystore
  filepath_manifest  = var.filepath_manifest
  enable_google_apis = module.enable_google_apis
}
