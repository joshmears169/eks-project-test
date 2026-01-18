locals {
  account_id = data.aws_caller_identity.current.account_id
  prefix = lower(trimsuffix(var.prefix, "-"))

  cluster_tag_key = "kubernetes.io/cluster/${var.cluster_name}"
}