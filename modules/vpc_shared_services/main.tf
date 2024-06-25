#
# VPC resources
#
resource "aws_vpc" "sharedservices_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "sharedservices_vpc"
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets.subnet)
  vpc_id                  = aws_vpc.sharedservices_vpc.id
  cidr_block              = lookup(element(var.private_subnets.subnet, count.index), "cidr_block")
  availability_zone       = join("",[var.region, lookup(element(var.private_subnets.subnet, count.index), "az")])     

  tags = merge(
    {
      Name        = "private"
    },
    var.tags
  )
}



resource "aws_subnet" "public" {
  count = length(var.public_subnets.subnet)
  vpc_id                  = aws_vpc.sharedservices_vpc.id
  cidr_block              = lookup(element(var.public_subnets.subnet, count.index), "cidr_block")
  availability_zone       = join("",[var.region, lookup(element(var.public_subnets.subnet, count.index), "az")])        
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "public"
    },
    var.tags
  )
}