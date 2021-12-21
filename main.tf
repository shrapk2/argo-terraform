# Very simple POC of ArgoCD-based Terraform with kubernetes-backed terraform state

terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    config_path      = "~/.kube/config"
  }
}


terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "hello_world_namespace" {
  metadata {
    labels = {
      app = "hello-world-example"
    }
    name = "hello-world-namespace"
  }
}

resource "kubernetes_deployment" "hello_world_deployment" {
  metadata {
    name = "kubernetes-example-deployment"
    namespace = "hello-world-namespace"
    labels = {
      app = "hello-world-example"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "hello-world-example"
      }
    }
    template {
      metadata {
        labels = {
          app = "hello-world-example"
        }
      }
      spec {
        container {
          image = "heroku/nodejs-hello-world"
          name  = "hello-world"
        }
      }
    }
  }
}
