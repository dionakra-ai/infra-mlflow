# Criar repositório ECR
resource "aws_ecr_repository" "example" {
  name = "example-repo"

  tags = {
    Name = "example-repo"
  }
}

# Criar cluster ECS
resource "aws_ecs_cluster" "example" {
  name = "example-cluster"

  tags = {
    Name = "example-cluster"
  }
}

# Criar definição de tarefa ECS
resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.example.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# Criar papel IAM para execução da tarefa ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# Criar serviço ECS
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.example_subnet_a.id, aws_subnet.example_subnet_b.id]
    security_groups  = [aws_security_group.example_sg.id]
    assign_public_ip = true
  }
}