resource "aws_eks_node_group" "system_nodes" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "system-ha-nodes"
  node_role_arn    = data.terraform_remote_state.bootstrap.outputs.node_role_arn
  subnet_ids      = module.vpc.public_subnets  

  scaling_config {
    desired_size = 2
    max_size     = 3 
    min_size     = 2
  }

  instance_types = ["t3.small"]

  labels = {
    intent = "control-plane"
  }
}