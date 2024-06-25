variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}



variable "public_subnets" {
  type = object({
    cidr_base = string
    subnet = list(object({
      cidr_block = string
      az      = string
    }))
  })
}

variable "private_subnets" {
  type = object({
    cidr_base = string
    subnet = list(object({
      cidr_block = string
      az      = string
    }))
  })
}

variable "region" {
  type = string
}

variable "routes" {
 
  type = list(string)
  
}