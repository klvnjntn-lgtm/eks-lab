variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_role_arn" {
  type        = string
  description = "The ARN of the IAM role for the EKS cluster"
}

variable "node_role_arn" {
  type        = string
  description = "The ARN of the IAM role for the nodes"
}