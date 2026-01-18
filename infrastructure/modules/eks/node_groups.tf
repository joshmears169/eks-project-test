# AWS EKS Node Group - Private
resource "aws_eks_node_group" "eks_ng_private" {
  count = var.provision_private_nodegroup ? 1 : 0
  
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.prefix}-eks-ng-private"
  node_role_arn   = aws_iam_role.nodegroup_role.arn
  subnet_ids      = var.private_subnet_ids
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = var.node_disk_size
  instance_types = var.private_ec2_instance_types
  
  
#   remote_access {
#     ec2_ssh_key = "eks-terraform-key"
#   }

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size    
    max_size     = var.node_max_size
  }

  labels = {
    "nodegroup" = "workloads"
    "workload"  = "apps"
  }


  update_config {
    max_unavailable = 1    
  }

  tags = merge(var.tags,
    { "Name" = "${local.prefix}-eks-ng-private" 
      "k8s.io/cluster-autoscaler/enabled" = "true" ## Only required if using Cluster Autoscaler
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    })

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.nodegroup_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodegroup_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodegroup_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.nodegroup_AmazonSSMManagedInstanceCore,
  ] 
}