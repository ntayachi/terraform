terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
  }
}

resource "kubernetes_deployment" "my_deployment" {
  metadata {
    name   = "my-deployment"
    labels = {
      app = "my-app"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      spec {
        container {
          image = var.image
          name  = "app"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "my_service" {
  metadata {
    name = "my-service"
  }
  spec {
    selector = {
      app = "my-app"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "my_ingress" {
  metadata {
    name = "my-ingress"
  }
  spec {
    backend {
      service_name = "my-service"
      service_port = 80
    }    
  }
}