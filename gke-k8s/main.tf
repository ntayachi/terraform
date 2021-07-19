terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.69.0"
    }
  }
}


provider "google" {
  project = var.project
  zone    = var.zone
}

data "google_client_config" "default" {
  depends_on = [module.gke]
}

data "google_container_cluster" "default" {
  name       = "my-cluster"
  depends_on = [module.gke]
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
}

module "gke" {
  source       = "./gke"
}

module "kubernetes" {
  depends_on = [module.gke]
  source     = "./kubernetes"
}