output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "oidc_url" {
  description = "The URL of the OIDC Identity Provider"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_arn" {
  description = "The ARN of the OIDC Identity Provider"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "cluster_ca_certificate" {
  description = "The CA data for the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_iam_role_arn" {
  description = "The ARN of the IAM role for the nodes"
  value       = var.node_role_arn
}

output "node_security_group_id" {
  description = "The security group ID attached to the EKS cluster/nodes"
  # EKS creates a default SG for the cluster and nodes to talk
value       = aws_security_group.node.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}