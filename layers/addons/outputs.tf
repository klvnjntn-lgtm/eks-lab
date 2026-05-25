data "kubernetes_service" "app_service" {
  metadata {
    name = "my-app-service"
  }
}

data "kubernetes_ingress_v1" "guestbook" {
  metadata {
    name      = "guestbook-ingress"
    namespace = "default"
  }
}
#
output "app_url" {
  description = "The DNS name of the Load Balancer"
  value = try(
    "http://${data.kubernetes_ingress_v1.guestbook.status[0].load_balancer[0].ingress[0].hostname}",
    "Pending..."
  )
}

