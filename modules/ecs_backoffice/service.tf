resource "aws_ecs_service" "service" {
  count = length(var.services)
   force_new_deployment = true

  name            = var.services[count.index].name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition[count.index].arn
  desired_count   = 1
  launch_type = "FARGATE"
    network_configuration {
    subnets          = var.subnet_ids
    security_groups  = concat([aws_security_group.sg_service[count.index].id])
    assign_public_ip = true
  }
 
   load_balancer {
    target_group_arn = aws_alb_target_group.service_tg[count.index].arn
    container_name   = var.services[count.index].name
    container_port   = var.services[count.index].container_port
  }
    tags = merge(
            var.tags
     )

}


