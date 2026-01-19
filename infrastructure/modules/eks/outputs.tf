output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_region" {
  description = "The AWS region where the EKS cluster is deployed"
  value       = var.region
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS Kubernetes API"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.cluster_master_role.name 
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.cluster_master_role.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer (for IRSA)"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN (for IRSA)."
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "alb_controller_irsa_role_arn" {
  value       = aws_iam_role.irsa_alb_controller.arn
  description = "IRSA role ARN for AWS Load Balancer Controller ServiceAccount"
}

output "cluster_autoscaler_irsa_role_arn" {
  value       = aws_iam_role.irsa_cluster_autoscaler.arn
  description = "IRSA role ARN for Cluster Autoscaler ServiceAccount"
}

# output "order_processor_irsa_role_arn" {
#   value = aws_iam_role.irsa_order_processor.arn
#   description = "IRSA role ARN for order processor ServiceAccount"
# }

# output "ops_readonly_role_arn" {
#   value = aws_iam_role.ops_readonly.arn
#   description = "IAM Role ARN for read-only operations access to the cluster"
# }

output "cluster_security_group_id" {
  description = "The security group ID associated with the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

# EKS Node Group Outputs - Private

output "node_group_private_name" {
  description = "Private Node Group Name"
  value       = length(aws_eks_node_group.eks_ng_private) > 0 ? aws_eks_node_group.eks_ng_private[0].node_group_name : null
}

output "node_group_private_id" {
  description = "Node Group 1 ID"
  value       = length(aws_eks_node_group.eks_ng_private) > 0 ? aws_eks_node_group.eks_ng_private[0].id : null
}

output "node_group_private_arn" {
  description = "Private Node Group ARN"
  value       = length(aws_eks_node_group.eks_ng_private) > 0 ? aws_eks_node_group.eks_ng_private[0].arn : null
}

output "node_group_private_status" {
  description = "Private Node Group status"
  value       = length(aws_eks_node_group.eks_ng_private) > 0 ? aws_eks_node_group.eks_ng_private[0].status : null
}

output "node_group_private_version" {
  description = "Private Node Group Kubernetes Version"
  value       = length(aws_eks_node_group.eks_ng_private) > 0 ? aws_eks_node_group.eks_ng_private[0].version : null
}

output "node_role_arn" {
  description = "IAM role ARN used by the managed node groups."
  value       = aws_iam_role.nodegroup_role.arn
}

output "update_kubeconfig_command" {
  description = "Command for developer to configure kubectl for this cluster."
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.region} --name ${aws_eks_cluster.eks_cluster.name}"
}