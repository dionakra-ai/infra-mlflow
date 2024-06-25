resource "aws_network_acl" "acl" {


  vpc_id = var.vpc_id
  subnet_ids = var.subnets_ids
  tags = {
    "Name" = "custom_acl"
  }
}

resource "aws_network_acl_rule" "acl_egress_rule" {
  count          = length(lookup(var.subnet_acl_rules,"egress"))
  network_acl_id = aws_network_acl.acl.id

  rule_number    = count.index+1
  egress         = true
  protocol       = lookup(element(lookup(var.subnet_acl_rules,"egress"), count.index), "protocol")
  rule_action    = lookup(element(lookup(var.subnet_acl_rules,"egress"), count.index), "rule_action")
  cidr_block     = lookup(element(lookup(var.subnet_acl_rules,"egress"), count.index), "cidr_block")
  from_port      = lookup(element(lookup(var.subnet_acl_rules,"egress"), count.index), "from_port")
  to_port        = lookup(element(lookup(var.subnet_acl_rules,"egress"), count.index), "to_port")
}

resource "aws_network_acl_rule" "acl_ingress_rule" {
  count          = length(lookup(var.subnet_acl_rules,"ingress"))
  network_acl_id = aws_network_acl.acl.id

  rule_number    = count.index+1
  egress         = false
  protocol       = lookup(element(lookup(var.subnet_acl_rules,"ingress"), count.index), "protocol")
  rule_action    = lookup(element(lookup(var.subnet_acl_rules,"ingress"), count.index), "rule_action")
  cidr_block     = lookup(element(lookup(var.subnet_acl_rules,"ingress"), count.index), "cidr_block")
  from_port      = lookup(element(lookup(var.subnet_acl_rules,"ingress"), count.index), "from_port")
  to_port        = lookup(element(lookup(var.subnet_acl_rules,"ingress"), count.index), "to_port")
}

