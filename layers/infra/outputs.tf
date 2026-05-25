output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  # The module uses this specific long name
  value = module.eks.cluster_ca_certificate
}

output "oidc_arn" {
  value = module.eks.oidc_arn
}

output "node_sg_id" {
  value = module.eks.node_security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# Keep your ECR outputs
output "ecr_repository_url" {
  value = aws_ecr_repository.guestbook_ui.repository_url
}

output "karpenter_node_role_name" {
  value = module.karpenter_iam.karpenter_node_role_name
}

output "oidc_url" {
  value = module.eks.oidc_url
}

output "interface_endpoint_ids" {
  value = module.vpc.interface_endpoint_ids
}