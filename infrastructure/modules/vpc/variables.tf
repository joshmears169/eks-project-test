variable "prefix" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of AZs to use (set to 3 for this test for high avaialbility)."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3 (this module is intended for 3 AZs)."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster used for subnet tagging so that Kubernetes can discover subnets."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}