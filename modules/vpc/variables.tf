variable "tags" {
  description = "Standard tags for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC resource"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the EKS cluster for tagging purposes"
  type        = string
  default     = "kj-eks-prod"
}