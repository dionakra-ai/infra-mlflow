resource "aws_security_group" "this" {
  name = "sg_${var.instance.name}"
  description = "Security Group da Instancia ${var.instance.name}"
  vpc_id = "${var.instance.vpc_id}"
  revoke_rules_on_delete = true
 
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

   tags = merge(
    {
      Name        = "${var.instance.name}"
    },
    merge(var.tags)
  )
}




resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.rules)
  type              = "ingress"
  from_port         = var.rules[count.index].from_port
  to_port           = var.rules[count.index].to_port
  protocol          = var.rules[count.index].protocol
  cidr_blocks       = var.rules[count.index].cidr_block
  security_group_id = aws_security_group.this.id
  
 
}


resource "aws_instance" "this" {
  ami = var.instance.ami
  depends_on = [ aws_security_group.this ]
  instance_type = var.instance.instance_type
  key_name =  var.instance.key_name
  disable_api_termination = terraform.workspace == "production" ? true : false
  disable_api_stop = terraform.workspace == "production" ? false : false
  user_data     = var.instance.instance_so =="linux" ? "${data.template_file.user_data_linux.rendered}" : "${data.template_file.user_data_windows.rendered}"
  user_data_replace_on_change = false
  iam_instance_profile =  var.iam_role_profile
  root_block_device {
    delete_on_termination = var.instance.ebs.delete_on_termination
    volume_size = var.instance.ebs.volume_size
    volume_type = var.instance.ebs.volume_type
  }
     network_interface {
     network_interface_id = var.instance.private_ips_mode ? "${aws_network_interface.static.id}" : "${aws_network_interface.dynamic.id}"
     device_index = 0
  }

 lifecycle {  ignore_changes = [ebs_block_device,root_block_device] }
dynamic "ebs_block_device" {
      for_each = length(keys(var.ebs_block_device))  == 0 ? [] : [var.ebs_block_device]
 content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = var.iops
           
    }

}

 tags = merge(
    {
      Name        = "${var.instance.name}"
    },
    merge(var.tags,local.backup)
  )
}

resource "aws_network_interface" "static" {
  subnet_id = var.instance.subnet_id
  private_ips = var.instance.private_ips
  security_groups = [aws_security_group.this.id]
  tags = merge(
    {
      Name        = "${var.instance.name}"
    },
    var.tags
  )
}

resource "aws_network_interface" "dynamic" {
  subnet_id = var.instance.subnet_id
  security_groups = [aws_security_group.this.id]
  tags = merge(
    {
      Name        = "${var.instance.name}"
    },
    var.tags
  )
}

resource "aws_eip" "eip" {
  count = var.instance.public_ip ? 1 : 0
  instance = aws_instance.this.id
  vpc      = true
}


 




