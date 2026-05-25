moved {
  from = aws_vpc.main
  to   = module.vpc.aws_vpc.main
}

moved {
  from = aws_internet_gateway.main
  to   = module.vpc.aws_internet_gateway.main
}

moved {
  from = aws_subnet.public[0]
  to   = module.vpc.aws_subnet.public[0]
}

moved {
  from = aws_subnet.public[1]
  to   = module.vpc.aws_subnet.public[1]
}

moved {
  from = aws_route_table.public
  to   = module.vpc.aws_route_table.public
}

moved {
  from = aws_vpc.main
  to   = module.vpc.aws_vpc.main
}

moved {
  from = aws_eks_cluster.this
  to   = module.eks.aws_eks_cluster.this
}

moved {
  from = aws_eks_cluster.this
  to   = module.eks.aws_eks_cluster.this
}

moved {
  from = aws_iam_role.cluster
  to   = module.eks.aws_iam_role.cluster
}

moved {
  from = aws_iam_role.nodes
  to   = module.eks.aws_iam_role.nodes
}

# If you had a node group at root level:
moved {
  from = aws_eks_node_group.this
  to   = module.eks.aws_eks_node_group.this
}

moved {
  from = aws_iam_role.karpenter_controller_role
  to   = module.karpenter_iam.aws_iam_role.karpenter_controller_role
}

moved {
  from = aws_iam_role.karpenter_node_role
  to   = module.karpenter_iam.aws_iam_role.karpenter_node_role
}