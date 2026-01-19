resource "awscc_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.bootstrap_admin_principal_arn
  type          = "STANDARD"
  access_policies = [
    {
      access_scope = {
        type       = "cluster"
      }
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    }
  ]
}

############################################
# Ops Readonly Access (EKS Access Entry)
############################################

# resource "awscc_eks_access_entry" "ops_readonly" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = aws_iam_role.ops_readonly.arn
#   username = "ops-user"
#   kubernetes_groups = ["ops-readonly"]
#   type          = "STANDARD"
#   access_policies = [
#     {
#       access_scope = {
#         type       = "cluster"
#       }
#       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy" # provides kubernetes api access but RBAC will enforce the read-only and ops namespace only access
#     }
#   ]
# }

# resource "aws_iam_role" "ops_readonly" {
#   name = "${var.cluster_name}-ops-user"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowAssumeFromOpsAliceWithSourceIp"
#         Effect = "Allow"
#         Action = "sts:AssumeRole"
#         Principal = {
#           AWS = var.ops_user_arn
#         }
#         Condition = {
#           IpAddress = {
#             "aws:SourceIp" = var.ops_source_ip_cidr
#           }
#         }
#       }
#     ]
#   })
# }