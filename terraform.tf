provider "kubernetes" {
  config_path = "./deploy/kubeconfig.yaml"
}

resource "kubernetes_deployment" "rosterbater" {
  metadata {
    name = "rosterbater-web-deployment"
    labels = {
      App = "rosterbater-web"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        App = "rosterbater-web"
      }
    }
    template {
      metadata {
        labels = {
          App = "rosterbater-web"
        }
      }
      spec {
        container {
          image = "gcr.io/google-samples/node-hello:1.0"
          name  = "hello-world"

          port {
            name = "web-port"
            container_port = 8080
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "rosterbater" {
  metadata {
    name = "rosterbater-lb"
  }
  spec {
    selector = {
      App = kubernetes_deployment.rosterbater.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = "web-port"
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.rosterbater.load_balancer_ingress[0].ip
}
