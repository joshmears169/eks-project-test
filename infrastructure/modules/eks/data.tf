data "aws_organizations_organization" "organization" {}

data "aws_caller_identity" "current" {}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true # Okay for test/dev, consider pinning for production to avoid unexpected changes
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true # Okay for test/dev, consider pinning for production to avoid unexpected changes
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true # Okay for test/dev, consider pinning for production to avoid unexpected changes
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true # Okay for test/dev, consider pinning for production to avoid unexpected changes
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_region" "current" {}