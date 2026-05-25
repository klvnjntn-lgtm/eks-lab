data "tls_certificate" "eks" {
url = module.eks.oidc_url
}