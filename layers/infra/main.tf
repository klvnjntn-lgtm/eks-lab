data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket         = "kelvin-terraform-state-permanent"
    key            = "bootstrap/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  tags            = var.tags
cluster_role_arn = data.terraform_remote_state.bootstrap.outputs.cluster_role_arn
  node_role_arn    = data.terraform_remote_state.bootstrap.outputs.node_role_arn
  }

module "karpenter_iam" {
  source       = "../../modules/karpenter"
  cluster_name = module.eks.cluster_name
  oidc_arn     = module.eks.oidc_arn
  oidc_url     = module.eks.oidc_url
  enable_helm  = false 
}



