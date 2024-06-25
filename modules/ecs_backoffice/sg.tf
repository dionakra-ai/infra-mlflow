resource "aws_security_group" "elb_service" {
  count = length(var.services)
  name        = "${var.services[count.index].name}_elb_sg"
  description = "Allow Cluster inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Http from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  
  ingress {
    description      = "TLS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

     tags = var.tags
}

resource "aws_security_group" "sg_service" {
  count = length(var.services)
  name        = "${var.services[count.index].name}_service_sg"
  description = "Allow Cluster inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP from elb"
    from_port        = var.services[count.index].container_port
    to_port          = var.services[count.index].container_port
    protocol         = "tcp"
    security_groups = [aws_security_group.elb_service[count.index].id]
   
  }

  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 tags = var.tags
}
