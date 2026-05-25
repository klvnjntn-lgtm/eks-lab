# --- Cluster Identity ---

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  type        = string
    default     = null # <-- Add this

}

# --- Networking ---

variable "vpc_id" {
  description = "The ID of the VPC where the cluster is located"
  type        = string
    default     = null # <-- Add this

}

variable "node_security_group_id" {
  description = "The ID of the security group attached to the EKS worker nodes"
  type        = string
  default     = null # <-- Add this
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
  default     = [] # <-- Add this
}

# --- IAM & Identity ---

variable "oidc_arn" {
  description = "The ARN of the OIDC Provider for the EKS cluster (used for IRSA)"
  type        = string
}

variable "oidc_url" {
  description = "The URL of the OIDC Provider for the EKS cluster"
  type        = string
}

variable "karpenter_controller_role_arn" {
  description = "The ARN of the IAM role for the Karpenter controller (if created outside)"
  type        = string
  default     = ""
}

variable "karpenter_version" {
  description = "The version of the Karpenter Helm chart to install"
  type        = string
  default     = "1.0.1"
}

variable "namespace" {
  description = "The Kubernetes namespace where Karpenter will be installed"
  type        = string
  default     = "karpenter"
}

variable "alb_controller_status" {
  description = "Dependency to ensure ALB controller is ready before Karpenter"
  type        = any
  default     = null
}

variable "enable_helm" {
  type    = bool
  default = false
}