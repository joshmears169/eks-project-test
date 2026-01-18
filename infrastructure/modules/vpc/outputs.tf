output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.standard.id
}

output "vpc_cidr" {
  description = "CIDR of the VPC."
  value       = aws_vpc.standard.cidr_block
}

output "azs" {
  description = "AZs used."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs (one per AZ)."
  value       = [for az in local.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)"
  value       = [for az in local.azs : aws_subnet.private[az].id]
}

output "private_route_table_ids" {
  description = "List of private route table IDs per AZ"
  value       = [for az in local.azs : aws_route_table.private_route_table[az].id]
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  value       = [for i in range(var.az_count) : local.public_subnet_cidrs[i]]
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  value       = [for i in range(var.az_count) : local.private_subnet_cidrs[i]]
}

##### For easy to understand mapping of AZ to subnet ID and CIDR #####

output "public_subnets_by_az" {
  description = "Map of AZ to subnet info for public subnets."
  value = {
    for az in local.azs : az => {
      id   = aws_subnet.public[az].id
      cidr = aws_subnet.public[az].cidr_block
    }
  }
}

output "private_subnets_by_az" {
  description = "Map of AZ to subnet info for private subnets."
  value = {
    for az in local.azs : az => {
      id   = aws_subnet.private[az].id
      cidr = aws_subnet.private[az].cidr_block
    }
  }
}