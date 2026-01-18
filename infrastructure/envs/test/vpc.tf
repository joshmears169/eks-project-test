module "vpc" {
  source = "../../modules/vpc"

  prefix     = local.name_prefix
  vpc_cidr = "10.0.0.0/16"
  az_count = 3

  cluster_name = local.cluster_name

  tags = local.common_tags
}