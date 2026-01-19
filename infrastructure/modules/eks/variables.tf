variable "region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
  default     = "eu-west-2"
}

variable "prefix" {
  description = "Name prefix for the resources"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_ec2_instance_types" {
  description = "List of EC2 instance types for private node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "incoming_orders_bucket_name" {
  type        = string
  description = "S3 bucket containing incoming orders"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "ekscluster"
}

variable "bootstrap_admin_principal_arn" {
  description = "ARN of the IAM user/role running kubectl - put your IAM user/role ARN here to get admin access to the cluster"
  type        = string
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster - NOT PODs CIDR"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "provision_private_nodegroup" {
  type    = bool
  default = true
}

variable "node_instance_types" {
  description = "List of EC2 instance types for node groups"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_disk_size" {
  description = "Disk size (GB) for node root volumes."
  type        = number
  default     = 20
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_admin_role_name" {
  description = "Name of an IAM role to bind to the system:masters Kubernetes RBAC group. This grants admin access to the cluster for anyone assuming the role."
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess"
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# EKS Node Group Variables