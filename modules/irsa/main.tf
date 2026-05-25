resource "aws_iam_role" "this" {
  name = "${var.cluster_name}-${var.service_account}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = var.oidc_arn }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account}"
        }
      }
    }]
  })
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.service_account
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.this.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}