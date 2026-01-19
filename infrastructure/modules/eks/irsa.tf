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

resource "aws_iam_policy" "alb_controller" {
  name        = "${local.prefix}-alb-controller-policy"
  description = "Permissions for AWS Load Balancer Controller (IRSA)"
  policy = file("${path.module}/policies/alb-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.irsa_alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

################################################
##### IRSA for Cluster Autoscaler
################################################

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeImages",
      "ec2:DescribeSubnets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "irsa_cluster_autoscaler" {
  name = "${local.prefix}-irsa-cluster-autoscaler"

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
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${local.cluster_autoscaler_sa_namespace}:${local.cluster_autoscaler_sa_name}"
          # Required by AWS
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags =var.tags
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${local.prefix}-cluster-autoscaler-policy"
  description = "Permissions for Cluster Autoscaler (IRSA)"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  role       = aws_iam_role.irsa_cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

#######################################################
##### IRSA for Order Processor S3 read permissions
#######################################################

# data "aws_iam_policy_document" "order_processor_s3_read" {
#   statement {
#     sid     = "ListIncomingOrdersBucket"
#     effect  = "Allow"
#     actions = ["s3:ListBucket"]
#     resources = [
#       "arn:aws:s3:::${var.incoming_orders_bucket_name}"
#     ]
#   }

#   statement {
#     sid     = "ReadIncomingOrdersObjects"
#     effect  = "Allow"
#     actions = ["s3:GetObject"]
#     resources = [
#       "arn:aws:s3:::${var.incoming_orders_bucket_name}/*"
#     ]
#   }
# }

# resource "aws_iam_policy" "order_processor_s3_read" {
#   name        = "${local.prefix}-order-processor-s3-read"
#   description = "Allow order-processor pods to list/read objects from incoming orders bucket"
#   policy      = data.aws_iam_policy_document.order_processor_s3_read.json
# }

# resource "aws_iam_role" "irsa_order_processor" {
#   name = "${local.prefix}-irsa-order-processor"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.oidc_provider.arn
#       }
#       Condition = {
#         StringEquals = {
#           # ServiceAccount identity
#           "${local.oidc_issuer}:sub" = "system:serviceaccount:${local.order_processor_namespace}:${local.order_processor_sa_name}"
#           # Required by AWS
#           "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
#         }
#       }
#     }]
#   })

#   tags =var.tags
# }

# resource "aws_iam_role_policy_attachment" "order_processor_attach_s3_read" {
#   role       = aws_iam_role.irsa_order_processor.name
#   policy_arn = aws_iam_policy.order_processor_s3_read.arn
# }