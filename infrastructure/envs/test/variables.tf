variable "project" {
  description = "Project name used for naming and tagging."
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, test, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "owner" {
  description = "Team who own the resources. Used in tags to help with things like FinOps."
  type        = string
  default     = "platform"
}

variable "repository" {
  description = "Repository name for tagging/audits."
  type        = string
  default     = "eks-project-test"
}

variable "bootstrap_admin_principal_arn" {
  description = "ARN of the IAM user/role running kubectl - put your IAM user/role ARN here to get admin access to the cluster"
  type        = string
}

variable "tags" {
  description = "Extra tags to apply to all AWS resources supplied by caller."
  type        = map(string)
  default     = {}
}