# Criar grupo de sub-rede do RDS
resource "aws_db_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = [aws_subnet.example_subnet_a.id, aws_subnet.example_subnet_b.id]
}

# Criar grupo de segurança
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}

resource "random_password" "db_password" {
  length           = 20
  special          = false
}

# Criar instância RDS
resource "aws_db_instance" "mlflowdb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.34"
  instance_class       = "db.t3.micro"
  db_name              = "mlflowdb"
  username             = "admin"
  password             = random_password.db_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  db_subnet_group_name = aws_db_subnet_group.example.name
}