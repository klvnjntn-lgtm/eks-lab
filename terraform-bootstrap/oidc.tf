resource "aws_iam_role" "github_oidc_role" {
  name = "GitHubAction-Terraform-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:klvnjntn-lgtm/cloud-infrastructure-project-kj:*"          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# Add this at the top of your file to get your account ID automatically
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "github_oidc_iam_limited" {
  name = "GitHubActionsIAMLimited"
  role = aws_iam_role.github_oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:PutRolePolicy",
          "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:AttachRolePolicy",
          "iam:DetachRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile", "iam:GetInstanceProfile",
          "iam:ListInstanceProfilesForRole", "iam:TagRole"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Server-Kelvin-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/Server-Kelvin-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Kelvin-Pro-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/Kelvin-Pro-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kelvin-cloud-project-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubAction-Terraform-Role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kj-eks-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*kj-app-sa-role*"
        ]
      },
      {
        Action = [
          "iam:GetOpenIDConnectProvider", "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider", "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:TagOpenIDConnectProvider"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*"
      },
      {
        Action   = ["sns:*", "cloudwatch:*", "logs:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["eks:*", "iam:ListRoles", "iam:*", "sts:GetCallerIdentity"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = "iam:PassRole"
        Condition = {
          StringEquals = {
            "iam:PassedToService" : ["eks.amazonaws.com", "ec2.amazonaws.com"]
          }
        }
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::kelvin-terraform-state-permanent",
          "arn:aws:s3:::kelvin-terraform-state-permanent/*"
        ]
      },
      {
        Action = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:304188066409:table/terraform-state-locking-permanent"
      },
      {
        Action = [
          "ec2:Describe*", "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway", "ec2:CreateRouteTable", "ec2:DeleteRouteTable",
          "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable", "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags", "ec2:DeleteTags", "ec2:CreateNatGateway", "ec2:DeleteNatGateway",
          "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:CreateVpcEndpoint", "ec2:DeleteVpcEndpoints",
          "ec2:DescribeVpcEndpoints", "ec2:ModifyVpcEndpoint", "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes", "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:CreatePolicy", "iam:DeletePolicy",
          "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions", "iam:GetRole",
          "iam:TagRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy",
          "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:AttachRolePolicy",
          "iam:DetachRolePolicy", "sqs:CreateQueue", "sqs:DeleteQueue", "sqs:GetQueueAttributes",
          "sqs:SetQueueAttributes", "sqs:ListQueueTags", "sqs:TagQueue", "sqs:UntagQueue",
          "sqs:GetQueueUrl", "sqs:ReceiveMessage"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Karpenter*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Karpenter*",
          "arn:aws:sqs:ap-southeast-1:${data.aws_caller_identity.current.account_id}:karpenter-*",
          "arn:aws:sqs:ap-southeast-1:${data.aws_caller_identity.current.account_id}:karpenter-kj-eks-prod-queue"
        ]
      },
      {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DeleteLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*"
        },
      {
        Action   = "sqs:ListQueues"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "cluster" {
  name = "kj-eks-prod-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "nodes" {
  name = "kj-eks-prod-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  policy_arn = each.value
  role       = aws_iam_role.nodes.name
}

output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  value = aws_iam_role.nodes.arn
}