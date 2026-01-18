locals {
  name_prefix  = "${var.project}-${var.env}"
  cluster_name = "${local.name_prefix}-eks"

  region = data.aws_region.current.region

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "Terraform"
      Owner       = var.owner
      Repository  = var.repository
    },
    var.tags
  )
}