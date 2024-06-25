
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sharedservices_vpc.id
  tags = merge(
    {
      Name        = "igw"
    },
    var.tags
 )

}

