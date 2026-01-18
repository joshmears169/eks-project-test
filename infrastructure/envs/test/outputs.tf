output "region" {
  description = "AWS region this environment is deployed into."
  value       = var.region
}

output "env" {
  description = "Environment name."
  value       = var.env
}

output "public_subnet_ids" {
  description = "Public subnet IDs (one per AZ) from the VPC module."
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks from the VPC module."
  value       = module.vpc.public_subnet_cidrs
}

output "public_subnets_by_az" {
  description = "Map of AZ to subnet info for public subnets from the VPC module."
  value       = module.vpc.public_subnets_by_az
}

output "private_route_table_ids" {
  description = "List of private route table IDs per AZ from the VPC module."
  value = module.vpc.private_route_table_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ) from the VPC module."
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks from the VPC module."
  value       = module.vpc.private_subnet_cidrs
}

output "private_subnets_by_az" {
  description = "Map of AZ to subnet info for private subnets from the VPC module."
  value       = module.vpc.private_subnets_by_az
}

output "vpc_id" {
  description = "VPC ID from the VPC module."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR of the VPC from the VPC module."
  value       = module.vpc.vpc_cidr
}

output "azs" {
  description = "AZs used from the VPC module."
  value       = module.vpc.azs
}


output "cluster_name" {
  description = "EKS cluster name."
  value       = local.cluster_name
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with the EKS cluster."
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_ca_certificate" {
  description = "Base64-encoded Kubernetes cluster CA certificate."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster (used for IRSA)."
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN (if created) for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "alb_controller_irsa_role_arn" {
  value       = module.eks.alb_controller_irsa_role_arn
  description = "IRSA role ARN for AWS Load Balancer Controller ServiceAccount"
}

output "node_group_names" {
  description = "Names of EKS managed node groups."
  value       = module.eks.node_group_private_name
}

output "node_role_arn" {
  description = "IAM role ARN used by node group."
  value       = module.eks.node_role_arn
}

output "update_kubeconfig_command" {
  description = "Command to configure kubectl for this cluster when it's up and running."
  value       = module.eks.update_kubeconfig_command
}

# output "argocd_capability_arn" {
#   description = "Name of the EKS capability enabled for GitOps."
#   value       = aws_eks_capability.argocd.arn
# }

# output "argocd_capability_status" {
#   description = "Status of the Argo CD capability (if available in provider schema)."
#   value       = try(aws_eks_capability.argocd.configuration.0.argo_cd.0.server_url, null)
# }