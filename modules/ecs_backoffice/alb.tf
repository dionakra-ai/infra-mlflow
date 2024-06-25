resource "aws_alb" "alb" {
  count = length(var.services)
  name               = "${var.services[count.index].name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.alb_subnet_ids
  security_groups    = [aws_security_group.elb_service[count.index].id ]

  
}



resource "aws_alb_target_group" "service_tg" {
  count = length(var.services)
  name     = "${var.services[count.index].name}-tg"
  port     = var.services[count.index].container_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
      enabled             = true
      healthy_threshold   = 5
      interval            = 300
      matcher             = 200
      path                = var.services[count.index].health_check
      port                = var.services[count.index].container_port
      protocol            = "HTTP"
      timeout             = 5
      unhealthy_threshold = 2
    }
  


}

resource "aws_alb_listener" "listeners" {
   count = length(var.services)
  load_balancer_arn = aws_alb.alb[count.index].arn
  port              = var.services[count.index].listner_port
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_tg[count.index].arn
  }
}
