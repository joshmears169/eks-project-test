################################################################################
##### VPC 
################################################################################

resource "aws_vpc" "standard" {
  cidr_block          = var.vpc_cidr
  enable_dns_support  = true
  enable_dns_hostnames = true
  
  tags = merge({Name = "${var.prefix}-vpc"}, var.tags)
}

################################################################################
##### Public Subnets and Routes
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.standard.id

  tags = merge(var.tags, {
    Name = "${var.prefix}-igw"
  })
}

# Public subnets (one per AZ)
resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : az => idx }

  vpc_id                  = aws_vpc.standard.id
  availability_zone       = each.key
  cidr_block              = local.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.prefix}-public-${each.key}"
    Tier = "public"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" ## So that Kubernetes/AWS Load Balncer Controller can discover subnets
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.standard.id

  tags = merge(
    { Name = "${var.prefix}-public-rtb" },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "to_internet_via_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

################################################################################
##### Private Subnets and Routes
################################################################################

resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : az => idx }
  
  vpc_id = aws_vpc.standard.id
  cidr_block = local.private_subnet_cidrs[each.value]
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = merge({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" ## So that Kubernetes//AWS Load Balncer Controller can discover subnets
    "kubernetes.io/role/internal-elb" = "1"
    Name = "${var.prefix}-private-${each.key}"
    Tier = "private"
    },
    var.tags)
} 

resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.standard.id

  tags = merge(
    { Name = "${var.prefix}-private-rtb-${each.key}" },
    var.tags
  )
}

resource "aws_route" "private_default" {
  for_each = aws_route_table.private_route_table

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

#################################################################################
##### Nat Gateways and EIPs
#################################################################################

# One per AZ, in the public subnet of that AZ
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.prefix}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, {
    Name = "${var.prefix}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.igw]
}