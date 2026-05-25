output "karpenter_node_role_arn" {
  description = "The ARN of the IAM role for Karpenter nodes"
  value       = aws_iam_role.karpenter_node_role.arn
}

output "karpenter_node_role_name" {
  description = "The Name of the IAM role for Karpenter nodes"
  value       = aws_iam_role.karpenter_node_role.name
}

output "karpenter_controller_role_arn" {
  description = "The ARN of the IAM role for the Karpenter controller"
  value       = aws_iam_role.karpenter_controller_role.arn
}