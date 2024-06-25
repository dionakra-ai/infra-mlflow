resource "aws_route_table" "private" {
  count = length(var.private_subnets.subnet)
  vpc_id = aws_vpc.sharedservices_vpc.id

  tags = merge(
    {
      Name        = "private"
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets.subnet)
  vpc_id = aws_vpc.sharedservices_vpc.id

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

resource "aws_route" "rout_to_internet" {
    depends_on = [
    aws_internet_gateway.igw
  ]
  count = length(aws_route_table.public.*.id)
  route_table_id            = aws_route_table.public[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
