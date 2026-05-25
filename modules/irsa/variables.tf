variable "cluster_name" {
  type = string
}

variable "oidc_url" {
  description = "The URL from the EKS cluster OIDC identity"
  type        = string
}

variable "oidc_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "service_account" {
  type = string
}