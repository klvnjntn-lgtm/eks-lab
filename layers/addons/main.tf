module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name           = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_endpoint       = data.terraform_remote_state.infra.outputs.cluster_endpoint
  oidc_arn               = data.terraform_remote_state.infra.outputs.oidc_arn
  oidc_url               = data.terraform_remote_state.infra.outputs.oidc_url
  
  vpc_id                 = data.terraform_remote_state.infra.outputs.vpc_id
  private_subnet_ids     = data.terraform_remote_state.infra.outputs.private_subnets
  node_security_group_id = data.terraform_remote_state.infra.outputs.node_sg_id
  
  karpenter_version      = "1.0.1"
  enable_helm            = true

  depends_on = [
    module.eks,
    module.vpc
  ]

  alb_controller_status = [
    data.terraform_remote_state.infra.outputs.vpc_id,
    data.terraform_remote_state.infra.outputs.interface_endpoint_ids
  ]
}

resource "aws_eks_access_entry" "karpenter_controller" {
  cluster_name  = data.terraform_remote_state.infra.outputs.cluster_name
  principal_arn = module.karpenter.karpenter_controller_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "karpenter_controller_view" {
  cluster_name  = data.terraform_remote_state.infra.outputs.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = module.karpenter.karpenter_controller_role_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "karpenter_nodes" {
  cluster_name      = data.terraform_remote_state.infra.outputs.cluster_name
  principal_arn     = module.karpenter.karpenter_node_role_arn
  type              = "EC2_LINUX"
}

module "alb_controller" {
  source = "../../modules/alb"
  oidc_arn = data.terraform_remote_state.infra.outputs.oidc_arn
  
  cluster_name                       = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_endpoint                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_data = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  vpc_id           = data.terraform_remote_state.infra.outputs.vpc_id  
}
#
module "argocd" {
  source = "../../modules/argocd"

  cluster_name           = data.terraform_remote_state.infra.outputs.cluster_name
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
}

module "irsa" {
  source         = "../../modules/irsa"
  namespace      = "default"
cluster_name = data.terraform_remote_state.infra.outputs.cluster_name
  oidc_url     = data.terraform_remote_state.infra.outputs.oidc_url
  oidc_arn     = data.terraform_remote_state.infra.outputs.oidc_arn
    service_account = "kj-app-sa"
}

