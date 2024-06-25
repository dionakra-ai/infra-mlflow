 variable "cluster_name" {
    type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

 variable "vpc_id" {
     type = string
 }

 variable "subnet_ids" {
     type = list(string)
 }

variable "services" {
    type = list(object({
    name = string
    memory = number
    cpu = number
    container_port = number
    service_registries = bool
    environment = string
    image = string
    listner_port = number
    health_check = string
    }))


}

variable "alb_subnet_ids" {
    type = list(string)
}
variable "user-registry" {
  type = string
}

variable "password-registry" {
  type = string
}

variable "s3-bucket" {
  type = string
}

variable "internal" {
  type = bool
}
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}