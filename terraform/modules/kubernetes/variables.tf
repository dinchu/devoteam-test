variable "region" {
  description = "The region in which resources will be created"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "filepath_manifest" {
  description = "Path to Kubernetes manifest files"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy to"
  type        = string
}

variable "memorystore" {
  description = "Flag to indicate if Memorystore APIs should be enabled"
  type        = bool
}

variable "memstore_apis" {
  description = "List of APIs for Memorystore"
  type        = list(string)
  default     = ["redis.googleapis.com"]
}

variable "network" {
  description = "Network to use"
  type        = string
}

variable "subnetwork" {
  description = "subnetwork to use"
  type        = string
}
