resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.standard.id
  service_name = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [for az in local.azs : aws_route_table.private_route_table[az].id]
}