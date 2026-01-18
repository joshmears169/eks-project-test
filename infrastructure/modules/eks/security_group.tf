resource "aws_security_group" "cluster" {
  name        = "${var.prefix}-${var.cluster_name}-security-group"
  description = "EKS Cluster Control Plane Security Group for managing EKS resources traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { "Name" = "${var.prefix}-${var.cluster_name}-security-group" })
}

resource "aws_vpc_security_group_egress_rule" "cluster_all" {
  security_group_id = aws_security_group.cluster.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}