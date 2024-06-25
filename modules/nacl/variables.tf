variable "vpc_id" {
  type        = string
  description = "Id of vpc"
}

variable "subnet_acl_rules" {
  type = object({
    egress = list(object({
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
    ingress = list(object({
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
  })
}

variable "subnets_ids" {
  type        = list
  description = "List of db subnets"
}
