locals {
  account_id = data.aws_caller_identity.current.account_id
  prefix = lower(trimsuffix(var.prefix, "-"))

  cluster_tag_key = "kubernetes.io/cluster/${var.cluster_name}"
  alb_sa_namespace = "kube-system"
  cluster_autoscaler_sa_namespace = "kube-system"
  alb_sa_name = "aws-load-balancer-controller"
  cluster_autoscaler_sa_name = "cluster-autoscaler"
  oidc_issuer = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
}