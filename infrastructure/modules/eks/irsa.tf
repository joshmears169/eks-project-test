################################################
##### IRSA for AWS Load Balancer Controller
################################################

resource "aws_iam_role" "irsa_alb_controller" {
  name = "${local.prefix}-irsa-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc_provider.arn
      }
      Condition = {
        StringEquals = {
          # ServiceAccount identity
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${local.alb_sa_namespace}:${local.alb_sa_name}"
          # Required by AWS
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags =var.tags
}

# IMPORTANT:
# The ALB Controller policy is big. Best practice is to keep it in a separate JSON file
# and load it with file(), OR paste the JSON policy from AWS docs here.
resource "aws_iam_policy" "alb_controller" {
  name        = "${local.prefix}-alb-controller-policy"
  description = "Permissions for AWS Load Balancer Controller (IRSA)"
  policy = file("${path.module}/policies/alb-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.irsa_alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}