variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "kj-eks-prod"
}

variable "admin_arn" {
  description = "ARN of the local IAM user to grant EKS admin access"
  type        = string
  default     = "arn:aws:iam::304188066409:role/GitHubAction-Terraform-Role"
}

variable "namespace" {
  type    = string
  default = "default"
}
