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

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}
