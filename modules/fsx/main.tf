resource "aws_security_group" "fsx" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.name
  }
  name = var.name
}

resource "aws_fsx_windows_file_system" "FSX" {
 
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  throughput_capacity = var.throughput_capacity
  deployment_type     = var.deployment_type
  aliases             = var.aliases
  security_group_ids  = [aws_security_group.fsx.id]
  self_managed_active_directory {
    dns_ips     = ["172.22.0.100", "172.22.2.100"]
    domain_name = "akadseguros.com.br"
    password    = var.passwordfsx
    username    = var.usernamefsx
  }
tags = merge({
    Name = var.name
},merge(var.tags,local.backup))
}