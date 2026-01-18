resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.cluster_name}"
  role_arn = aws_iam_role.cluster_master_role.arn
  version = var.cluster_version

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids ### EKS Control Plane AWS-Managed ENIs are put in these subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]
}