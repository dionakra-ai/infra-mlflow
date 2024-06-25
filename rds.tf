# Criar grupo de sub-rede do RDS
resource "aws_db_subnet_group" "example" {
  name       = "example-subnet-group-mlflow"
  subnet_ids = var.db_subnets
}

# Criar grupo de segurança
resource "aws_security_group" "mlflowdb_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  identifier           = var.db_name
  db_name              = var.db_name
  username             = var.db_user
  password             = random_password.db_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.mlflowdb_sg.id]
  db_subnet_group_name = aws_db_subnet_group.example.name
}