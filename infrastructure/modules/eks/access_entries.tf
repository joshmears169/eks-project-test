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