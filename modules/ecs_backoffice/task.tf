resource "aws_ecs_task_definition" "ecs_task_definition" {
    count = length(var.services)
    family                = var.services[count.index].name

        container_definitions = <<DEFINITION
    [
      {
          "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/aws/ecs/${aws_ecs_cluster.ecs_cluster.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "ecs"
          }
        },
        "portMappings": [
          {
            "hostPort": ${var.services[count.index].container_port},
            "protocol": "tcp",
            "containerPort": ${var.services[count.index].container_port}
          }
        ],
        "cpu": 0,
        "environment": [
          ${var.services[count.index].environment}
        ],
        "repositoryCredentials": {
          "credentialsParameter": "${aws_secretsmanager_secret.user_default[count.index].arn}"
        },
        "memory": ${var.services[count.index].memory},
        "image": "${var.services[count.index].image}",
        "essential": true,
        "name": "${var.services[count.index].name}"
      }
    ] 
    DEFINITION

    execution_role_arn = aws_iam_role.execution.arn

    task_role_arn = aws_iam_role.task.arn

    requires_compatibilities = ["FARGATE"]
    memory = var.services[count.index].memory
    cpu = var.services[count.index].cpu

    network_mode = "awsvpc"

    tags = merge({
            Name = "task_role"
        },
        var.tags
    )
}