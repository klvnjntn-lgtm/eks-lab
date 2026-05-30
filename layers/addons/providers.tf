data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "kelvin-terraform-state-permanent"
    key    = "dev/infrastructure/terraform.tfstate" 
    region = "ap-southeast-1"
  }
}
terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "kelvin-terraform-state-permanent"
    key    = "dev/ad/terraform.tfstate" 
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking-permanent"
  }

  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm", version = "~> 2.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0" }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}


provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infra.outputs.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infra.outputs.cluster_name]
      command     = "aws"
    }
  }
}