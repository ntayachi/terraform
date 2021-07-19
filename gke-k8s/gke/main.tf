terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.69.0"
    }
  }
}

resource "google_container_cluster" "default" {
  name                     = "my-cluster"
  network                  = "default"
  subnetwork               = "default"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "my_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.default.name
  node_count = 1

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}