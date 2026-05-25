data "aws_iam_policy_document" "node_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_node_role" {
  name               = "KarpenterNodeRole-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.node_trust.json
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ssm_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "karpenter_controller" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "Permissions for Karpenter to manage EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeSpotPriceHistory", # ADD THIS
          "pricing:GetProducts"           # ADD THIS
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:sqs:ap-southeast-1:304188066409:karpenter-${var.cluster_name}-queue"
      },
      {
    "Effect": "Allow",
    "Action": [
        "ec2:DeleteLaunchTemplate",
        "ec2:CreateLaunchTemplate",
        "ec2:DescribeLaunchTemplates"
    ],
    "Resource": "*"
},
      {
        Action = [
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:eks:ap-southeast-1:304188066409:cluster/${var.cluster_name}"
      },
      {
        # NEW: Instance Profile Management for v1.0.1
        Action = [
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:TagInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Resource = aws_iam_role.karpenter_node_role.arn
      },
      {
        Action = "ssm:GetParameter"
        Effect = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/aws/service/*"      
      }
    ]
  })
}

resource "aws_iam_role_policy" "karpenter_controller_eks_describe" {
  name = "karpenter-cluster-discovery"
role = aws_iam_role.karpenter_controller_role.name # <--- CHANGE THIS

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:eks:ap-southeast-1:304188066409:cluster/kj-eks-prod"
      }
    ]
  })
}

resource "aws_iam_role" "karpenter_controller_role" {
  name = "KarpenterControllerRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          # Use the variable, NOT the module reference
          Federated = var.oidc_arn 
        }
        Condition = {
          StringEquals = {
# 1. FIXED: Changed 'karpenter' namespace to 'kube-system'
            "${replace(var.oidc_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:karpenter",
            # 2. FIXED: Added the Audience (aud) claim
            "${replace(var.oidc_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}