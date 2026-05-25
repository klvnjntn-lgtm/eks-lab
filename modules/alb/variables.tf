variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "cluster_ca_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "oidc_arn" {
  description = "The ARN of the OIDC Provider for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the cluster is running"
  type        = string
}