resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "karpenter-${var.cluster_name}-queue"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

resource "helm_release" "karpenter" {
  count = var.enable_helm ? 1 : 0
  namespace        = "kube-system"
  create_namespace = true
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.0.1"
  wait = true
  timeout         = 300
  atomic          = false
  cleanup_on_fail = false 
  depends_on = [var.alb_controller_status]

values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      cluster_name            = var.cluster_name
      cluster_endpoint        = var.cluster_endpoint
      interruption_queue_name = aws_sqs_queue.karpenter_interruption.name
      controller_role_arn     = aws_iam_role.karpenter_controller_role.arn 
    }
    )
  ]

set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

set {
    name  = "settings.clusterCIDR"
    value = "172.20.0.0/16" 
  }

set {
  name  = "settings.featureGates.drift"
  value = "false"
}

}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sqs:SendMessage"
      Effect    = "Allow"
      Resource  = aws_sqs_queue.karpenter_interruption.arn
      Principal = { Service = ["events.amazonaws.com", "sqs.amazonaws.com"] }
    }]
  })
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
resource "kubectl_manifest" "karpenter_node_class" {
  count = var.enable_helm ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiFamily = "AL2023"
      role      = aws_iam_role.karpenter_node_role.name
      
      amiSelectorTerms = [
        { id = "ami-07190a8c9aed1dc5f" }
      ]
      
      subnetSelectorTerms = [
        { tags = { "karpenter.sh/discovery" = var.cluster_name } }
      ]

      securityGroupSelectorTerms = [
        { id = var.node_security_group_id }
      ]
    }
  })

  # Option B: Wait for the controller/CRDs to exist
  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  count = var.enable_helm ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            name  = "default"
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
          }
          requirements = [
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"] },
            { key = "karpenter.k8s.aws/instance-category", operator = "In", values = ["c", "m", "r"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] }
          ]
        }
      }
      limits = { cpu = 1000 }
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "30s"
      }
    }
  })

  # Also depends on the class created above to ensure sequential setup
  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_node_class
  ]
}