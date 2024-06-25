resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    {
      Name        = "igw"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "private" {
  count = length(var.private_subnets.subnet)
  allocation_id = aws_eip.private[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "natgw_private"
    },
    var.tags
  )
}

resource "aws_eip" "private" {
  count = length(var.private_subnets.subnet)
  vpc = true
  tags = merge(
    {
     Name        = "private"
    },
    var.tags
  )
}