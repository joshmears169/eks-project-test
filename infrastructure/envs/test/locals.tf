locals {
  name_prefix  = "${var.project}-${var.env}"
  cluster_name = "${local.name_prefix}-eks"

  ops_user_arn = "arn:aws:iam::1234566789001:user/ops-alice"
  ops_source_ip_cidr = "52.94.236.248/32"

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