# Criar VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Criar sub-redes
resource "aws_subnet" "example_subnet_a" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "example-subnet-a"
  }
}

resource "aws_subnet" "example_subnet_b" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "example-subnet-b"
  }
}

# Criar Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "example-igw"
  }
}

# Criar rota para a Internet Gateway
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table_association" "example_subnet_a_assoc" {
  subnet_id      = aws_subnet.example_subnet_a.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_route_table_association" "example_subnet_b_assoc" {
  subnet_id      = aws_subnet.example_subnet_b.id
  route_table_id = aws_route_table.example_route_table.id
}