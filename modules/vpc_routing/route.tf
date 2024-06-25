resource "aws_route_table" "private" {
  count = length(var.private_subnets.subnet)
  vpc_id = aws_vpc.main_vpc.id
 

  tags = merge(
    {
      Name        = "private"
    },
    var.tags
  )
}



resource "aws_route_table" "public" {
  count = length(var.public_subnets.subnet)
  vpc_id = aws_vpc.main_vpc.id


  tags = merge(
    {
      Name        = "public"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets.subnet)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id  
}



resource "aws_route_table_association" "public" {
  count = length(var.public_subnets.subnet)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}



locals {
  routes_routing = setproduct(setunion(aws_route_table.public.*.id,aws_route_table.private.*.id),var.routes)
  routes_routing2 = setproduct(setunion(aws_route_table.public.*.id,aws_route_table.private.*.id),var.routes_vpn)
}

resource "aws_route" "routing_all" {
  count = length(local.routes_routing)
  route_table_id            = tolist(local.routes_routing)[count.index][0]
  destination_cidr_block    = tolist(local.routes_routing)[count.index][1]
  transit_gateway_id = var.transit_gw_id
  
}

resource "aws_route" "routing_vpn_azure" {
  count = length(local.routes_routing2)
  route_table_id            = tolist(local.routes_routing2)[count.index][0]
  destination_cidr_block    = tolist(local.routes_routing2)[count.index][1]
  transit_gateway_id = var.transit_gw_id
  
}

resource "aws_route" "rout_to_internet" {
    depends_on = [
    aws_internet_gateway.igw
  ]
  count = length(setunion(aws_route_table.public.*.id))
  route_table_id            = aws_route_table.public[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  
}

resource "aws_route" "route_to_internet_private" {
  count = length(aws_route_table.private.*.id)
  route_table_id            = aws_route_table.private[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private[count.index].id
}

 