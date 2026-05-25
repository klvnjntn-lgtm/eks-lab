# --- 1. Pull the Permanent IAM from Bootstrap ---
data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket         = "kelvin-terraform-state-permanent"
    key            = "bootstrap/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.public_subnets # Using public for cost-optimization
    endpoint_private_access = true 
    endpoint_public_access  = true  
  }
  
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# --- 3. OIDC Provider (Tied to this specific Cluster) ---
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# --- 4. Admin Access Entries ---
resource "aws_eks_access_entry" "kelvin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::304188066409:user/terraform-kelvin"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "kelvin_admin" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::304188066409:user/terraform-kelvin"

  access_scope {
    type = "cluster"
  }
}

# --- 5. Security Groups ---
resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_to_node" {
  description              = "Allow cluster control plane to communicate with nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}