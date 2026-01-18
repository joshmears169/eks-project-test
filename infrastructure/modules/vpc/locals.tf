locals {
  azs = slice(data.aws_availability_zones.availability_zones.names, 0, var.az_count)
  subnet_newbits = 4

  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + var.az_count)]
}