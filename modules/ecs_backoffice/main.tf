
resource "aws_cloudwatch_log_group" "ecs_cloudwatch_log_group" {
    
    name              = "/aws/ecs/${aws_ecs_cluster.ecs_cluster.name}"
    retention_in_days = 180

    tags = merge({
            Name = "ecs_cloudwatch_log_group"
        },var.tags
    )
}

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = var.cluster_name
    
    capacity_providers  = ["FARGATE"]
     default_capacity_provider_strategy {
      capacity_provider = "FARGATE"
     
  }
      
      setting {
      name  = "containerInsights"
      value = "enabled"

      
 }
    tags = merge({
            Name = var.cluster_name
        },
            var.tags
    )
}











   resource "aws_secretsmanager_secret" "user_default" {
       count = length(var.services)
     name        = "${var.services[count.index].name}-secret-"
       tags = merge({
             Name = "${var.cluster_name}_key_manager"
         },
            var.tags
     )
   }

 resource "aws_secretsmanager_secret_version" "secret_val" {
      count = length(var.services)
     secret_id     = aws_secretsmanager_secret.user_default[count.index].id
     secret_string = jsonencode({"password": "${var.password-registry}", "username": "${var.user-registry}"})
   }